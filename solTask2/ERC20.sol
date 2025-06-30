// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleERC20 {
    // 代币信息
    string public name;
    string public symbol;
    uint8 public decimals;
    
    // 代币总供应量
    uint256 private _totalSupply;
    
    // 合约所有者
    address public owner;
    
    // 余额映射
    mapping(address => uint256) private _balances;
    
    // 授权额度映射
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // 事件定义
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // 构造函数
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
        
        // 初始铸造给合约部署者
        _mint(msg.sender, initialSupply);
    }
    
    // 修饰器：只有所有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // 查询总供应量
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    // 查询账户余额
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    // 转账功能
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    // 查询授权额度
    function allowance(address _owner, address spender) public view returns (uint256) {
        return _allowances[_owner][spender];
    }
    
    // 授权功能
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    // 代扣转账功能
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        
        // 检查授权额度是否足够
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        
        // 减少授权额度（防止重入攻击）
        unchecked {
            _approve(from, msg.sender, currentAllowance - amount);
        }
        
        _transfer(from, to, amount);
        return true;
    }
    
    // 增发代币（仅所有者）
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    
    // 内部转账实现
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "Transfer from the zero address");
        require(_balances[from] >= amount, "Transfer amount exceeds balance");
        
        // 更新余额
        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
    }
    
    // 内部授权实现
    function _approve(address _owner, address spender, uint256 amount) internal {
        require(_owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    
    // 内部铸造实现
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Mint to the zero address");
        
        _totalSupply += amount;
        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
    }
}