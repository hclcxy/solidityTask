// SPDX-License-Identifier: MIT
pragma solidity  ~0.8;

contract ReverseString{

    //✅ 反转字符串 (Reverse String)
// 题目描述：反转一个字符串。输入 "abcde"，输出 "edcba"
  function reverse(string memory _input) public pure returns (string memory) {
        // 将字符串转换为字节数组
        bytes memory strBytes = bytes(_input);
        bytes memory reversed = new bytes(strBytes.length);
        
        // 反转字节数组
        for(uint i = 0; i < strBytes.length; i++) {
            reversed[i] = strBytes[strBytes.length - i - 1];
        }
        
        // 将字节数组转换回字符串
        return string(reversed);
    }
    
}