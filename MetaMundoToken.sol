// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

library SafeMath {
  	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
  	}

  	function div(uint256 a, uint256 b) internal pure returns (uint256) {
	    uint256 c = a / b;
		return c;
  	}

  	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
  	}

  	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

abstract contract OwnerHelper {
  	address private _owner;

  	event OwnershipTransferred(address indexed preOwner, address indexed nextOwner);

  	modifier onlyOwner {
		require(msg.sender == _owner, "OwnerHelper: caller is not owner");
		_;
  	}

  	constructor() {
            _owner = msg.sender;
  	}

       function owner() public view virtual returns (address) {
           return _owner;
       }

  	function transferOwnership(address newOwner) onlyOwner public {
            require(newOwner != _owner);
            require(newOwner != address(0x0));
            address preOwner = _owner;
    	    _owner = newOwner;
    	    emit OwnershipTransferred(preOwner, newOwner);
  	}
}

contract MetaMundoToken is IERC20, OwnerHelper {

    using SafeMath for uint256;

    uint256 public constant SECONDS_IN_A_MONTH = 2_628_288;

    address public constant WALLET_TOKEN_SALE = address(0x71677dDADB4be1F2C15ae722B5665475bF7Bed7f);
    address public constant WALLET_ECO_SYSTEM = address(0x5668b3fa2D82505c89213f7aa53CcaCcc8620e15);
    address public constant WALLET_RnD = address(0x4ef5a9FC33B33cDEf3A866aFA1F5aF092bD9B9B5);
    address public constant WALLET_MARKETING = address(0x9De31f65f4e32C1b157925b73ec161b8CAf3947C);
    address public constant WALLET_TEAM_N_ADVISOR = address(0x8ac0fDdca4488Ae52ecCF50a56b67A3fE8e5Ddae);
    address public constant WALLET_IDO = address(0xC4dC6aca12B41a2339DEb3d797834547D5A99Dac);
    address public constant WALLET_DEV = address(0x15A1BFc48e5C90e5820edE03BBBf491930643824);
    address public constant WALLET_STRATEGIC_PARTNERSHIP = address(0xB0AF6F69b1420b0A9a062B09f7e8fEeDd802FA27);

    uint256 public constant SUPPLY_TOKEN_SALE = 200_000_000e18;
    uint256 public constant SUPPLY_ECO_SYSTEM = 600_000_000e18;
    uint256 public constant SUPPLY_RnD = 400_000_000e18;
    uint256 public constant SUPPLY_MARKETING = 200_000_000e18;
    uint256 public constant SUPPLY_TEAM_N_ADVISOR = 200_000_000e18;
    uint256 public constant SUPPLY_IDO = 200_000_000e18;
    uint256 public constant SUPPLY_DEV = 100_000_000e18;
    uint256 public constant SUPPLY_STRATEGIC_PARTNERSHIP = 100_000_000e18;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) public _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    
    uint public _deployTime;
    
    constructor(string memory name_, string memory symbol_) 
    {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = 2_000_000_000e18;
        _balances[msg.sender] = _totalSupply;
        _deployTime = block.timestamp;
    }
    
    function name() public view returns (string memory) 
    {
        return _name;
    }
    
    function symbol() public view returns (string memory) 
    {
        return _symbol;
    }
    
    function decimals() public pure returns (uint8) 
    {
        return 18;
    }
    
    function totalSupply() external view virtual override returns (uint256) 
    {
        return _totalSupply;
    }

    function deployTime() external view returns (uint)
    {
        return _deployTime;
    }

    function balanceOf(address account) external view virtual override returns (uint256) 
    {
        return _balances[account];
    }
    
    function transfer(address recipient, uint amount) public virtual override returns (bool) 
    {
        _transfer(msg.sender, recipient, amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) external view override returns (uint256) 
    {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint amount) external virtual override returns (bool) 
    {
        uint256 currentAllownace = _allowances[msg.sender][spender];
        require(currentAllownace >= amount, "ERC20: Transfer amount exceeds allowance");
        _approve(msg.sender, spender, currentAllownace, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 currentAmount, uint256 amount) internal virtual 
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(currentAmount == _allowances[owner][spender], "ERC20: invalid currentAmount");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) 
    {
        _transfer(sender, recipient, amount);
        emit Transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance, currentAllowance - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual 
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(isCanTransfer(sender, amount) == true, "TokenLock: invalid token transfer");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance.sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
    }
    
    function isCanTransfer(address holder, uint256 amount) public view returns (bool)
    {
        if(holder == WALLET_TOKEN_SALE)
        {
            return true;
        }
        // EcoSystem
        else if(holder == WALLET_ECO_SYSTEM)
        {
            uint releaseTime = _deployTime;
            if(releaseTime <= block.timestamp)
            {
                uint256 releasableBalance = (SUPPLY_ECO_SYSTEM / 100) * 15;
                
                uint pastMonth = ((block.timestamp - releaseTime) / SECONDS_IN_A_MONTH) + 1;
                uint256 releasedBalance = pastMonth * (releasableBalance / 36);
                if(releasedBalance >= amount && _balances[holder] >= amount)
                {
                    return true;
                }

                return false;
            }
            else 
            {
                return false;
            }
        }
        // R&D
        else if(holder == WALLET_RnD)
        {
            // 3개월 락업 이후
            uint releaseTime = _deployTime + SECONDS_IN_A_MONTH * 3;
            if(releaseTime <= block.timestamp)
            {
                // 3개월 락업 이후 계산 하는거니까 3빼줌
                uint pastMonth = ((block.timestamp - releaseTime) / SECONDS_IN_A_MONTH) - 3;
                uint256 releasedBalance = pastMonth * (SUPPLY_RnD / 36);
                if(releasedBalance >= amount && _balances[holder] >= amount)
                {
                    return true;
                }
                return false;
            }
            else 
            {
                return false;
            }            
        }
        // Marketing
        else if(holder == WALLET_MARKETING)
        {
            uint releaseTime = _deployTime;
            if(releaseTime <= block.timestamp)
            {
                uint pastMonth = ((block.timestamp - releaseTime) / SECONDS_IN_A_MONTH) + 1;
                uint256 releasedBalance = pastMonth * (SUPPLY_MARKETING / 36);
                if(releasedBalance >= amount && _balances[holder] >= amount)
                {
                    return true;
                }
                return false;
            }
            else
            {
                return false;
            }
        }
        // Team & Advisor
        else if(holder == WALLET_TEAM_N_ADVISOR)
        {
            uint releaseTime = _deployTime + (SECONDS_IN_A_MONTH * 5);
            if(releaseTime <= block.timestamp)
            {
                // 48개월 동안 해제 단 5개월 이후니까 5를 빼줘야 함
                //uint pastMonth = SafeMath.div(block.timestamp - releaseTime, SECONDS_IN_A_MONTH) - 5;
                uint pastMonth = ((block.timestamp - releaseTime) / SECONDS_IN_A_MONTH) - 5;
                    uint256 releasedBalance = pastMonth * (SUPPLY_TEAM_N_ADVISOR / 48);
                    if(releasedBalance >= amount && _balances[holder] >= amount)
                    {
                        return true;
                    }
                return false;
            }
            else 
            {
                return false;
            }
        }
        // IDO
        else if(holder == WALLET_IDO)
        {
            uint releaseTime = _deployTime;
            if(releaseTime <= block.timestamp)
            {
                // 첫달 부터 해제니까 +1
                uint pastMonth = SafeMath.div(block.timestamp - releaseTime, SECONDS_IN_A_MONTH) + 1;
                    uint256 releasedBalance = pastMonth * (SUPPLY_IDO / 48);
                    if(releasedBalance >= amount && _balances[holder] >= amount)
                    {
                        return true;
                    }

                return false;
            }
            else 
            {
                return false;
            }
        }
        // Dev
        else if(holder == WALLET_DEV)
        {
            uint releaseTime = _deployTime;
            if(releaseTime <= block.timestamp)
            {
                uint pastMonth = SafeMath.div(block.timestamp - releaseTime, SECONDS_IN_A_MONTH) + 1;
                    uint256 releasedBalance = pastMonth * (SUPPLY_DEV / 36);
                    if(releasedBalance >= amount && _balances[holder] >= amount)
                    {
                        return true;
                    }

                return false;
            }
            else 
            {
                return false;
            }
        }
        // Stategic Partnership
        else if(holder == WALLET_STRATEGIC_PARTNERSHIP)
        {
            uint releaseTime = _deployTime + (SECONDS_IN_A_MONTH * 5);
            if(releaseTime <= block.timestamp)
            {
                uint pastMonth = SafeMath.div(block.timestamp - releaseTime, SECONDS_IN_A_MONTH) - 5;
                    uint256 releasedBalance = pastMonth * (SUPPLY_STRATEGIC_PARTNERSHIP / 36);
                    if(releasedBalance >= amount && _balances[holder] >= amount)
                    {
                        return true;
                    }
                return false;
            }
            else 
            {
                return false;
            }
        }
        
        return true;
    }
}