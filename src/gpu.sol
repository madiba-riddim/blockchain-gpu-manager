// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin IERC20
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract GPUApproval {
    IERC20  public gpuToken;
    address public professor;
    uint public requestCount = 0;
    uint public pendingCount = 0;

    enum Status { Pending, Approved, Rejected }

    struct Request {
        address requester;
        string detail;
        Status status;
        uint gpuIndex;
        string machine;
        uint hour;
        uint endTime;         // 歸還截止時間
        bool returned;        // 是否已還機
        string rejectReason;
    }

    uint public constant GPU_PRICE_PER_HOUR = 1e18;   // 1 token per hour
    uint public constant MAX_HOURS = 72;
    uint public constant DEPOSIT = 10e18; // 10 GPUQToken per request

    mapping(uint => Request) public requests;
    mapping(uint => uint)    public depositOf; // requestId -> deposit amount

    event Requested(
        uint indexed id,
        address indexed requester,
        string detail,
        uint gpuIndex,
        string machine,
        uint hour
    );
    event Approved(uint indexed id);
    event Rejected(uint indexed id, string reason);
    event Returned(uint indexed id, address indexed user);
    event DepositRefunded(uint indexed id, address indexed user, uint amount);
    event DepositForfeited(uint indexed id, address indexed user, uint amount);

    constructor(address _professor, address _token) {
        professor = _professor;
        gpuToken  = IERC20(_token);
    }

    function getPendingRequestIds() public view returns (uint[] memory) {
        uint[] memory temp = new uint[](pendingCount);
        uint idx = 0;
        for (uint i = 0; i < requestCount; i++) {
            if (requests[i].status == Status.Pending) {
                temp[idx] = i;
                idx++;
            }
        }
        return temp;
    }

    function applyGPU(
        string memory detail,
        uint gpuIndex,
        string memory machine,
        uint hour
    ) public returns (uint) {
        require(hour > 0, "Hours must be > 0");
        require(hour <= MAX_HOURS, "Exceeds max hours");
        uint cost = hour * GPU_PRICE_PER_HOUR;

        // 收取借用費與押金
        require(
            gpuToken.transferFrom(msg.sender, address(this), cost + DEPOSIT),
            "Token transfer failed"
        );

        uint end = block.timestamp + hour * 3600;

        requests[requestCount] = Request(
            msg.sender,
            detail,
            Status.Pending,
            gpuIndex,
            machine,
            hour,
            end,
            false,
            ""
        );
        depositOf[requestCount] = DEPOSIT;

        emit Requested(requestCount, msg.sender, detail, gpuIndex, machine, hour);
        requestCount++;
        pendingCount++;
        assert(pendingCount >= 0);
        return requestCount - 1;
    }

    // 學生主動還機
    function returnGPU(uint id) public {
        require(msg.sender == requests[id].requester, "not borrower");
        require(!requests[id].returned, "already returned");
        require(requests[id].status == Status.Approved, "not approved");
        // require(block.timestamp >= requests[id].endTime, "not ended yet"); // 可自行調整
        requests[id].returned = true;
        emit Returned(id, msg.sender);
    }

    function approve(uint id) public {
        require(msg.sender == professor, "Only professor can approve.");
        require(requests[id].status == Status.Pending, "Not pending.");
        requests[id].status = Status.Approved;
        pendingCount--;
        assert(pendingCount >= 0);
        emit Approved(id);
    }

    function reject(uint id, string memory reason) public {
        require(msg.sender == professor, "Only professor can reject.");
        require(requests[id].status == Status.Pending, "Not pending.");
        requests[id].status = Status.Rejected;
        requests[id].rejectReason = reason;
        pendingCount--;
        // 申請被駁回，退還押金
        uint deposit = depositOf[id];
        if (deposit > 0) {
            gpuToken.transfer(requests[id].requester, deposit);
            depositOf[id] = 0;
            emit DepositRefunded(id, requests[id].requester, deposit);
        }
        assert(pendingCount >= 0);
        emit Rejected(id, reason);
    }

    // 教授審查通過後退還押金（還機後 call）
    function refundDeposit(uint id) public {
        require(msg.sender == professor, "Only professor");
        require(requests[id].returned, "not returned");
        uint deposit = depositOf[id];
        require(deposit > 0, "No deposit to refund");
        gpuToken.transfer(requests[id].requester, deposit);
        depositOf[id] = 0;
        emit DepositRefunded(id, requests[id].requester, deposit);
    }

    // 教授沒收押金（還機前違規呼叫）
    function forfeitDeposit(uint id) public {
        require(msg.sender == professor, "Only professor");
        require(!requests[id].returned, "already returned");
        uint deposit = depositOf[id];
        require(deposit > 0, "No deposit to forfeit");
        depositOf[id] = 0;
        emit DepositForfeited(id, requests[id].requester, deposit);
        // 押金直接留在合約
    }

    function getRequest(uint id) public view returns (
        address requester,
        string memory detail,
        Status status,
        uint gpuIndex,
        string memory machine,
        uint hour,
        uint endTime,
        bool returned,
        string memory rejectReason
    ) {
        Request storage r = requests[id];
        return (r.requester, r.detail, r.status, r.gpuIndex, r.machine, r.hour, r.endTime, r.returned, r.rejectReason);
    }

    // 交易市場部分
    struct Sale {
        address seller;
        uint    amount;
        uint    pricePerToken; // in ETH
        bool    active;
    }

    mapping(uint => Sale) public sales;
    uint public saleCount;

    function listForSale(uint amount, uint pricePerToken) public {
        // 將 amount 轉為最小單位
        uint tokenAmount = amount * 1e18;
        require(gpuToken.transferFrom(msg.sender, address(this), tokenAmount), "transfer failed");
        sales[saleCount] = Sale(msg.sender, tokenAmount, pricePerToken, true);
        //emit SaleListed(saleCount, msg.sender, tokenAmount, pricePerToken);
        saleCount++;
    }

    function buy(uint saleId) public payable {
        Sale storage s = sales[saleId];
        require(s.active, "not active");

        // amount 是以最小單位儲存，轉回幾顆 token
        uint tokenCount = s.amount / 1e18;
        uint totalPrice = tokenCount * s.pricePerToken;

        require(msg.value >= totalPrice, "not enough ETH");
        gpuToken.transfer(msg.sender, s.amount);
        payable(s.seller).transfer(totalPrice);
        s.active = false;
        //emit SaleCompleted(saleId, msg.sender, s.amount, totalPrice);

        // 多餘 ETH 退回
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
    }

}
