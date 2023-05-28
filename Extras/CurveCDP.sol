// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Initializable {
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) ||
                (!AddressUpgradeable.isContract(address(this)) &&
                    _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(
            !_initializing && _initialized < version,
            "Initializable: contract is already initialized"
        );
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

interface TOKEN {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mintRequest(address __minter, address to, uint256 _amount) external;
}

interface IDEPOSITER {
    function deposit( uint256 _amount, bool _lock, bool _stake, address _user) external;
}

contract Curve_CDP is Initializable, OwnableUpgradeable {
    TOKEN public CRV_Token;
    TOKEN public sdCRV3_Token;
    address public DEPOSITER;
    TOKEN public SD_CRV_Token;
    uint256 public depositors;

    mapping(address => uint256) public TrackBalance;

    function initialize() public initializer {
        CRV_Token = TOKEN(0x2e38CE9970eE1D0E11a13254ef5A07Fdc36cCc1c);
        sdCRV3_Token = TOKEN(0x003f4E8562aa0C131568B041787201410860520e);
        SD_CRV_Token = TOKEN(0x4346fb688Df6f3060AAD17c9442c453A6AFdb3e1);
        DEPOSITER = address(0x9B55f3C867b7eA8d707a482E9F6F1d8E850Ae6bE);
       __Ownable_init();
    }

    function setCRV(TOKEN _address) public onlyOwner {
        CRV_Token = TOKEN(_address);
    }

    function setsdCRV3(TOKEN _address) public onlyOwner {
        sdCRV3_Token = TOKEN(_address);
    }

    function setSD_CRV_Token(TOKEN _address) public onlyOwner {
        SD_CRV_Token = TOKEN(_address);
    }

    function setDEPOSITER(address _address) public onlyOwner {
        DEPOSITER = address(_address);
    }

    function getCRVBalance(address _address) public view returns (uint256) {
        return TOKEN(CRV_Token).balanceOf(_address);
    }

    function getCRVDecimals() public view returns (uint256) {
        return TOKEN(CRV_Token).decimals();
    }

    function getsdCRV3Balance(address _address) public view returns (uint256) {
        return TOKEN(sdCRV3_Token).balanceOf(_address);
    }

    function getsdCRV3CDecimals() public view returns (uint256) {
        return TOKEN(sdCRV3_Token).decimals();
    }

    function sdCRV3_Pot() public view returns (uint256) {
        return TOKEN(sdCRV3_Token).balanceOf(address(this));
    }

    function CRV_Depositor(uint256 _amount, bool _lock, bool _stake, address _user) internal {
        IDEPOSITER(DEPOSITER).deposit(_amount, _lock, _stake, _user);
    }

    function Approve_D(uint256 _amount) public {
        Approve_Depositor(_amount);
    }

    function Approve_Depositor(uint256 _amount) internal {
        TOKEN(CRV_Token).approve(address(DEPOSITER), _amount);
    }

    function Deposit_CRV( uint256 _amount, bool _lock) public payable {
        require(_amount >= 0, "Zero Amount is not acceptable");
        TOKEN(CRV_Token).transferFrom(msg.sender, address(this), _amount);
        TOKEN(sdCRV3_Token).mintRequest(address(this), msg.sender, _amount);
      
        // CRV_Depositor(_amount, _lock, _stake, address(this));
        CRV_Depositor(_amount, _lock, true, address(this));  // stake ko by default true kerdia hay zeeshan bhai k kehne pay

        uint256 userAmount = TrackBalance[msg.sender];
        if (userAmount == 0) depositors = depositors + 1;
        TrackBalance[msg.sender] = userAmount + (_amount);
    }

    
    function Deposit_sdCRV( uint256 _amount ) public payable {
        require(_amount >= 0, "Zero Amount is not acceptable");

        TOKEN(SD_CRV_Token).transferFrom(msg.sender, address(this), _amount);
        TOKEN(sdCRV3_Token).mintRequest(address(this), msg.sender, _amount);
      
        uint256 userAmount = TrackBalance[msg.sender];
        if (userAmount == 0) depositors = depositors + 1;
        TrackBalance[msg.sender] = userAmount + (_amount);
    }

    function withdraw_sdCRV3() public payable onlyOwner {
        __withdraw_sdCRV3();
    }

    function __withdraw_sdCRV3() internal {
        TOKEN(sdCRV3_Token).transfer(owner(), getsdCRV3Balance(address(this)));
    }
    
    function withdraw_any(TOKEN _address) public onlyOwner {
        __withdraw_any(_address);
    }

    function __withdraw_any(TOKEN _address) internal {
        TOKEN(_address).transfer(owner(), TOKEN(_address).balanceOf(address(this)));
    }
}