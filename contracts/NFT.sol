// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./UniversalONFT721.sol";

contract ZeroPortalNFT is UniversalONFT721 {
    constructor(
        uint256 _minGasToStore,
        address _layerZeroEndpoint,
        uint _startMintId,
        uint _endMintId
    )
        UniversalONFT721(
            "ZeroPortalNFT",
            "ZRP",
            _minGasToStore,
            _layerZeroEndpoint,
            _startMintId,
            _endMintId
        )
    {}
}
