// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";


interface IERC2981Royalties {
    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _value - the sale price of the NFT asset specified by _tokenId
    /// @return _receiver - address of who should be sent the royalty payment
    /// @return _royaltyAmount - the royalty payment amount for value sale price
    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);
}

abstract contract ERC2981PerTokenRoyalties is IERC2981Royalties {
    
    mapping(uint256 => uint256) internal _royalties;

    function _setTokenRoyalty(
        uint256 id,
        uint256 value
    ) internal {
        require(value <= 10000, 'ERC2981Royalties: Too high');

        _royalties[id] = value;
    }

    /// @inheritdoc IERC2981Royalties
    function royaltyInfo(uint256 tokenId, uint256 value)
        external
        view
        override
        virtual
        returns (address receiver, uint256 royaltyAmount)
    {
        return (address(0), (value * _royalties[tokenId]) / 10000);
    }
}

contract winwinCollectionV1 is Initializable,ERC721Upgradeable,ERC2981PerTokenRoyalties {
    
    uint256 private _tokenIds;
    uint256 private _total;
    mapping (uint256 => address) private _itemCreator;
    address _owner;
    string _mainUri;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function initialize(string memory _name, string memory _symbol) public initializer  {
        ERC721Upgradeable.__ERC721_init(_name, _symbol);
        _owner = msg.sender;
        _tokenIds  = 1000;
    }
    
    modifier onlyOwner{
        require(msg.sender == _owner, 'Only Owner Can Execute');
        _;
    }
    
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function createItem(uint256 _royalty) external {
        _safeMint(msg.sender, _tokenIds);
        _setTokenRoyalty(_tokenIds, _royalty);
        _itemCreator[_tokenIds] = msg.sender;
        _total++;
        _tokenIds++;
    }
    
    
    function bulkMinter(uint numOfTokens, uint256 _royalty) external virtual {
        require( numOfTokens <= 40, "Number of Collections Exceeds Count");
        uint i;
        for (i = _tokenIds+1; i < numOfTokens+_tokenIds+1; i++) {
            _safeMint(msg.sender, i);
            _itemCreator[i] = msg.sender;
            _setTokenRoyalty(i, _royalty);
        }
        _tokenIds = i;
        _total += numOfTokens;
    }
    
    function bulkTransfer(address[] memory to, uint[] memory tokenIds) external virtual{
        require( to.length == tokenIds.length, "Lenght not matched, Invalid Format");
        require( to.length <= 40, "You can transfer max 40 tokens");
        for(uint i = 0; i < to.length; i++){
            safeTransferFrom(msg.sender, to[i], tokenIds[i]);
        }
    }
    
    function multiSendTokens(address to, uint[] memory tokenIds) external virtual{
        require( tokenIds.length <= 40, "You can transfer max 40 tokens");
        for(uint i = 0; i < tokenIds.length; i++){
            safeTransferFrom(msg.sender, to, tokenIds[i]);
        }
    }

    function setUri(string memory _main) external onlyOwner{
        _mainUri = _main;
    }

    function _baseURI() internal view override returns (string memory) {
        return _mainUri;
    }
    
    function tokenURI(uint256 _tkid) public view override returns (string memory) {
        require(_exists(_tkid), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(_baseURI(),_toString(_tkid),".json"));
    }
    
    function tokenCreator(uint256 tokenId) external view returns (address) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _itemCreator[tokenId];
    }

    function totalSupply() external view returns (uint256) {
        return _total;
    }
    
    function royaltyInfo(uint256 tokenId, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        return (_itemCreator[tokenId], (value * _royalties[tokenId]) / 10000);
    }


    /**
     * @dev Converts a uint256 to its ASCII string decimal representation.
     */
    function _toString(uint256 value) internal pure virtual returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
            let m := add(mload(0x40), 0xa0)
            // Update the free memory pointer to allocate.
            mstore(0x40, m)
            // Assign the `str` to the end.
            str := sub(m, 0x20)
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }
}


// {address: "0xDb920bf86e5849ad81ce33c6cC3d70156711d2Fa"}

