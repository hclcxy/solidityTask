// SPDX-License-Identifier: MIT
pragma solidity ~0.8;

contract Roman {
   // 用 solidity 实现整数转罗马数字
    struct Numeral {
        string symbol;
        uint value;
    }
    
    Numeral[] private numerals;
    
    constructor() {
        // 初始化罗马数字符号和对应的值，按从大到小排序
        numerals.push(Numeral("M", 1000));
        numerals.push(Numeral("CM", 900));
        numerals.push(Numeral("D", 500));
        numerals.push(Numeral("CD", 400));
        numerals.push(Numeral("C", 100));
        numerals.push(Numeral("XC", 90));
        numerals.push(Numeral("L", 50));
        numerals.push(Numeral("XL", 40));
        numerals.push(Numeral("X", 10));
        numerals.push(Numeral("IX", 9));
        numerals.push(Numeral("V", 5));
        numerals.push(Numeral("IV", 4));
        numerals.push(Numeral("I", 1));
    }
    
    // 将整数转换为罗马数字
    function intToRoman(uint num) public view returns (string memory) {
        require(num > 0 && num < 4000, "Number must be between 1 and 3999");
        
        string memory roman = "";
        uint remaining = num;
        
        for (uint i = 0; i < numerals.length; i++) {
            while (remaining >= numerals[i].value) {
                roman = string(abi.encodePacked(roman, numerals[i].symbol));
                remaining -= numerals[i].value;
            }
        }
        
        return roman;
    }
}

contract RomanToInteger {
    // 映射罗马字符到对应的数值
    mapping(bytes1 => uint) private romanValues;
    
    constructor() {
        // 初始化罗马字符对应的数值
        romanValues['I'] = 1;
        romanValues['V'] = 5;
        romanValues['X'] = 10;
        romanValues['L'] = 50;
        romanValues['C'] = 100;
        romanValues['D'] = 500;
        romanValues['M'] = 1000;
    }
    
    // 将罗马数字字符串转换为整数
    function romanToInt(string memory s) public view returns (uint) {
        bytes memory roman = bytes(s);
        uint total = 0;
        uint prevValue = 0;
        
        for (uint i = 0; i < roman.length; i++) {
            bytes1 currentChar = roman[i];
            require(romanValues[currentChar] > 0, "Invalid Roman numeral character");
            
            uint currentValue = romanValues[currentChar];
            
            // 如果前一个值小于当前值，则需要减去两倍的前值
            // (因为之前已经加过一次了)
            if (prevValue < currentValue) {
                total += currentValue - 2 * prevValue;
            } else {
                total += currentValue;
            }
            
            prevValue = currentValue;
        }
        
        // 验证是否为有效的罗马数字格式
        require(validateRoman(s), "Invalid Roman numeral format");
        
        return total;
    }
    
    // 验证罗马数字格式是否正确
    function validateRoman(string memory s) private view returns (bool) {
        bytes memory roman = bytes(s);
        
        // 检查字符是否有效
        for (uint i = 0; i < roman.length; i++) {
            if (romanValues[roman[i]] == 0) {
                return false;
            }
        }
        
        // 检查减法规则是否正确应用
        for (uint i = 0; i < roman.length - 1; i++) {
            uint current = romanValues[roman[i]];
            uint next = romanValues[roman[i+1]];
            
            // 检查减法组合是否有效
            if (current < next) {
                if (!(current == 1 && (next == 5 || next == 10)) &&
                    !(current == 10 && (next == 50 || next == 100)) &&
                    !(current == 100 && (next == 500 || next == 1000))) {
                    return false;
                }
                
                // 检查连续减法是否有效（如IIV是不允许的）
                if (i > 0 && romanValues[roman[i-1]] <= next) {
                    return false;
                }
            }
        }
        
        return true;
    }
}


contract SortedArrayMerger {
    /**
     * @dev 合并两个有序数组并返回新数组
     * @param arr1 第一个有序数组
     * @param arr2 第二个有序数组
     * @return 合并后的新有序数组
     */
    function mergeAndReturnNewArray(
        uint[] memory arr1,
        uint[] memory arr2
    ) public pure returns (uint[] memory) {
        uint m = arr1.length;
        uint n = arr2.length;
        uint[] memory merged = new uint[](m + n);
        
        uint i = 0;  // arr1指针
        uint j = 0;  // arr2指针
        uint k = 0;  // merged指针

        // 从前向后合并
        while (i < m && j < n) {
            if (arr1[i] < arr2[j]) {
                merged[k] = arr1[i];
                i++;
            } else {
                merged[k] = arr2[j];
                j++;
            }
            k++;
        }

        // 处理剩余元素
        while (i < m) {
            merged[k] = arr1[i];
            i++;
            k++;
        }

        while (j < n) {
            merged[k] = arr2[j];
            j++;
            k++;
        }

        return merged;
    }
}
contract MergerDemo is SortedArrayMerger {
    function demonstrateMerge() public pure returns (uint[] memory) {
        uint[] memory arr1 = new uint[](3);
        arr1[0] = 1;
        arr1[1] = 3;
        arr1[2] = 5;
        
        uint[] memory arr2 = new uint[](4);
        arr2[0] = 2;
        arr2[1] = 4;
        arr2[2] = 6;
        arr2[3] = 8;
        
        return mergeAndReturnNewArray(arr1, arr2);
        // 返回: [1, 2, 3, 4, 5, 6, 8]
    }
}

contract BinarySearch {

    function binarySearchWithIndex(
        uint[] memory array,
        uint target
    ) public pure returns (int) {
        uint left = 0;
        uint right = array.length;
        
        while (left < right) {
            uint mid = left + (right - left) / 2;
            
            if (array[mid] == target) {
                return int(mid); // 找到目标，返回索引
            } else if (array[mid] < target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }
        
        return -1; // 未找到，返回-1
    }
}
contract Demo is BinarySearch {
     function demonstrate() public pure returns (int) {
         uint[] memory arr = new uint[](5);
         arr[0] = 2;
         arr[1] = 3;
         arr[2] = 4;
         arr[3] = 6;
         arr[4] = 7;
        return binarySearchWithIndex(arr, 6);   
    }
}