// SPDX-License-Identifier: MIT
pragma solidity ~0.8;

contract Voting{
//     ✅ 创建一个名为Voting的合约，包含以下功能：
// 一个mapping来存储候选人的得票数





    //记录候选人和票数
    mapping (address => uint256) public candidateVoting;
    //候选人数
    address[] public candidates;

    // 一个vote函数，允许用户投票给某个候选人
    function Vote(address _candidate) public {
        require(_candidate!=address(0), "address error");
        candidates.push(_candidate);
        candidateVoting[_candidate]++;
       
    }    

    //// 一个getVotes函数，返回某个候选人的得票数
    function getVotes(address _candidate) public view returns (uint256){
        require(_candidate != address(0), "address error");
        return candidateVoting[_candidate];
    }
    // 一个resetVotes函数，重置所有候选人的得票数
    function resetVotes() public {
        for (uint256 i = 0; i < candidates.length; i++){
            candidateVoting[candidates[i]] = 0;
        }   
    }
}