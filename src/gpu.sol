// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GPUApproval {
    address public professor;
    uint public requestCount = 0;
    uint public pendingCount = 0;

    enum Status { Pending, Approved, Rejected }

    struct Request {
        address requester;
        string detail;
        Status status;
        uint gpuIndex;         // 新增：申請哪張 GPU
        string machine;        // 新增：目標機器名稱
        string rejectReason;   // 新增：教授駁回理由
    }

    mapping(uint => Request) public requests;

    event Requested(
        uint indexed id,
        address indexed requester,
        string detail,
        uint gpuIndex,
        string machine
    );
    event Approved(uint indexed id);
    event Rejected(uint indexed id, string reason);

    constructor(address _professor) {
        professor = _professor;
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
    function applyGPU(string memory detail, uint gpuIndex, string memory machine) public returns (uint) {
        requests[requestCount] = Request(
            msg.sender,
            detail,
            Status.Pending,
            gpuIndex,
            machine,
            "" // rejectReason 空字串
        );
        emit Requested(requestCount, msg.sender, detail, gpuIndex, machine);
        requestCount++;
        pendingCount++;
        assert(pendingCount >= 0);
        return requestCount - 1;
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
        assert(pendingCount >= 0);
        emit Rejected(id, reason);
    }

    function getRequest(uint id) public view returns (
        address requester,
        string memory detail,
        Status status,
        uint gpuIndex,
        string memory machine,
        string memory rejectReason
    ) {
        Request storage r = requests[id];
        return (r.requester, r.detail, r.status, r.gpuIndex, r.machine, r.rejectReason);
    }
}

