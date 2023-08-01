// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IONFT721.sol";
import "./ONFT721Core.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// NOTE: this ONFT contract has no public minting logic.
// must implement your own minting logic in child classes
contract ONFT721 is ONFT721Core, ERC721, IONFT721, ERC721Enumerable {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _minGasToTransfer,
        address _lzEndpoint
    ) ERC721(_name, _symbol) ONFT721Core(_minGasToTransfer, _lzEndpoint) {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function tokenOfOwnerPage(
        address owner,
        uint256 pageNumber,
        uint256 pageSize
    ) external view returns (uint256, uint256[] memory, string[] memory) {
        uint256 total = balanceOf(owner);
        uint256 start = pageNumber * pageSize;
        require(start < total, "pageNumber input error");
        uint256 end;
        if (start + pageSize > total) {
            end = total;
        } else {
            end = start + pageSize;
        }
        uint256[] memory tokenIds = new uint256[](end - start);
        string[] memory tokenURIs = new string[](end - start);
        uint256 count = 0;
        for (uint256 i = start; i < end; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(owner, i);
            tokenIds[count] = tokenId;
            tokenURIs[count] = tokenURI(tokenId);
            count++;
        }
        return (total, tokenIds, tokenURIs);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ONFT721Core, ERC721, IERC165, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IONFT721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _debitFrom(
        address _from,
        uint16,
        bytes memory,
        uint _tokenId
    ) internal virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ONFT721: send caller is not owner nor approved"
        );
        require(
            ERC721.ownerOf(_tokenId) == _from,
            "ONFT721: send from incorrect owner"
        );
        _transfer(_from, address(this), _tokenId);
    }

    function _creditTo(
        uint16,
        address _toAddress,
        uint _tokenId
    ) internal virtual override {
        require(
            !_exists(_tokenId) ||
                (_exists(_tokenId) && ERC721.ownerOf(_tokenId) == address(this))
        );
        if (!_exists(_tokenId)) {
            _safeMint(_toAddress, _tokenId);
        } else {
            _transfer(address(this), _toAddress, _tokenId);
        }
    }
}
