// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/gpu.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockGPUQToken is ERC20 {
    constructor() ERC20("GPU Quota Token", "GPUQ") {}
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract GPUApprovalTest is Test {
    GPUApproval public approval;
    MockGPUQToken public token;

    address professor = address(0x1);
    address student1  = address(0x2);
    address student2  = address(0x3);

    function setUp() public {
        token = new MockGPUQToken();
        approval = new GPUApproval(professor, address(token));
        // 分發 token 給學生
        token.mint(student1, 1000e18);
        token.mint(student2, 1000e18);
    }

    function testStudentCanApplyAndPayDeposit() public {
        vm.startPrank(student1);
        token.approve(address(approval), 1000e18);
        uint id = approval.applyGPU("AI homework", 0, "workstation1", 2);
        vm.stopPrank();

        (
            address requester, 
            string memory detail, 
            GPUApproval.Status status, 
            uint gpuIndex, 
            string memory machine, 
            uint hour, 
            uint endTime,
            bool returned, 
            string memory rejectReason
        ) = approval.getRequest(id);

        assertEq(requester, student1);
        assertEq(detail, "AI homework");
        assertEq(uint(status), 0); // Pending
        assertEq(gpuIndex, 0);
        assertEq(machine, "workstation1");
        assertEq(hour, 2);
        assertEq(returned, false);

        // 保證金正確扣除
        uint expectCost = 2 * approval.GPU_PRICE_PER_HOUR() + approval.DEPOSIT();
        assertEq(token.balanceOf(student1), 1000e18 - expectCost);
        assertEq(token.balanceOf(address(approval)), expectCost);
        assertEq(approval.depositOf(id), approval.DEPOSIT());
    }

    function testStudentReturnAndProfessorRefundDeposit() public {
        // 先申請並approve
        vm.startPrank(student1);
        token.approve(address(approval), 1000e18);
        uint id = approval.applyGPU("train", 1, "A", 1);
        vm.stopPrank();

        // 教授審核通過
        vm.prank(professor);
        approval.approve(id);

        // 時間推進到結束
        vm.warp(block.timestamp + 3600);

        // 學生歸還
        vm.prank(student1);
        approval.returnGPU(id);

        // 教授退押金
        uint before = token.balanceOf(student1);
        vm.prank(professor);
        approval.refundDeposit(id);
        uint after_ = token.balanceOf(student1);

        assertEq(approval.depositOf(id), 0);
        assertEq(after_ - before, approval.DEPOSIT());
    }

    function testRejectWillRefundDeposit() public {
        // 申請
        vm.startPrank(student2);
        token.approve(address(approval), 1000e18);
        uint id = approval.applyGPU("testing", 2, "machineB", 1);
        vm.stopPrank();

        uint before = token.balanceOf(student2);
        // 教授 reject
        vm.prank(professor);
        approval.reject(id, "Already borrowed");
        uint after_ = token.balanceOf(student2);

        assertEq(after_ - before, approval.DEPOSIT());
        assertEq(approval.depositOf(id), 0);
    }

    function testForfeitDeposit() public {
        // 申請
        vm.startPrank(student1);
        token.approve(address(approval), 1000e18);
        uint id = approval.applyGPU("forfeit test", 0, "X", 1);
        vm.stopPrank();

        // 教授 approve
        vm.prank(professor);
        approval.approve(id);

        // 教授沒收押金（未歸還時）
        uint before = token.balanceOf(address(approval));
        vm.prank(professor);
        approval.forfeitDeposit(id);
        uint after_ = token.balanceOf(address(approval));
        assertEq(after_ - before, 0); // 押金留在合約內
        assertEq(approval.depositOf(id), 0);
    }

    function testOnlyProfessorCanApproveRejectRefundForfeit() public {
        vm.startPrank(student1);
        token.approve(address(approval), 1000e18);
        uint id = approval.applyGPU("foo", 1, "x", 1);
        vm.stopPrank();

        // 學生不能 approve/reject/refund/forfeit
        vm.prank(student1);
        vm.expectRevert("Only professor can approve.");
        approval.approve(id);

        vm.prank(student1);
        vm.expectRevert("Only professor can reject.");
        approval.reject(id, "No");

        vm.prank(student1);
        vm.expectRevert("Only professor");
        approval.refundDeposit(id);

        vm.prank(student1);
        vm.expectRevert("Only professor");
        approval.forfeitDeposit(id);
    }
}
