Token balances mapping
    mapping(address => uint256) private balances;

    Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    Constructor sets deployer as owner and mints initial supply
    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** decimals;
        balances[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    Transfer tokens
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "Transfer to zero address");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    Check allowance for spender
    function allowance(address tokenOwner, address spender) external view returns (uint256) {
        return allowances[tokenOwner][spender];
    }

    Mint new tokens (owner only)
    function mint(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "Mint to zero address");

        uint256 mintAmount = amount * 10 ** decimals;
        totalSupply += mintAmount;
        balances[account] += mintAmount;
        emit Transfer(address(0), account, mintAmount);
    }

    Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
// 
End
// 
