// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/gpu.sol";

contract GPUApprovalTest is Test {
    GPUApproval public approval;

    address professor = address(0x1);
    address student1 = address(0x2);
    address student2 = address(0x3);

    function setUp() public {
        // 每次測試前都會重新部署合約
        approval = new GPUApproval(professor);
    }

    function testStudentCanApply() public {
        vm.prank(student1);
        uint id = approval.applyGPU("AI homework", 0, "workstation1");
        assertEq(id, 0);

        (address requester, string memory detail, GPUApproval.Status status, uint gpuIndex, string memory machine, string memory rejectReason)
            = approval.getRequest(id);
        assertEq(requester, student1);
        assertEq(detail, "AI homework");
        assertEq(uint(status), 0); // Pending
        assertEq(gpuIndex, 0);
        assertEq(machine, "workstation1");
        assertEq(bytes(rejectReason).length, 0);
    }

    function testProfessorCanApprove() public {
        // 先讓學生申請
        vm.prank(student1);
        uint id = approval.applyGPU("for training", 1, "machineA");
        // 教授核准
        vm.prank(professor);
        approval.approve(id);

        (, , GPUApproval.Status status, , , ) = approval.getRequest(id);
        assertEq(uint(status), 1); // Approved
    }

    function testProfessorCanRejectWithReason() public {
        vm.prank(student2);
        uint id = approval.applyGPU("testing", 2, "machineB");
        // 教授駁回
        vm.prank(professor);
        approval.reject(id, "Already borrowed");

        (, , GPUApproval.Status status, , , string memory rejectReason) = approval.getRequest(id);
        assertEq(uint(status), 2); // Rejected
        assertEq(rejectReason, "Already borrowed");
    }

    function testOnlyProfessorCanApproveOrReject() public {
        vm.prank(student1);
        uint id = approval.applyGPU("foo", 3, "pc3");

        // 學生自己不能approve/reject
        vm.prank(student1);
        vm.expectRevert("Only professor can approve.");
        approval.approve(id);

        vm.prank(student1);
        vm.expectRevert("Only professor can reject.");
        approval.reject(id, "No");
    }

    function testPendingCount() public {
        // 連續申請兩筆
        vm.prank(student1);
        approval.applyGPU("A", 0, "a");
        vm.prank(student2);
        approval.applyGPU("B", 1, "b");

        assertEq(approval.pendingCount(), 2);

        // 教授核准一筆
        vm.prank(professor);
        approval.approve(0);
        assertEq(approval.pendingCount(), 1);

        // 教授駁回一筆
        vm.prank(professor);
        approval.reject(1, "No");
        assertEq(approval.pendingCount(), 0);
    }
}

