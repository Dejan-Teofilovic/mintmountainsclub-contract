// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract Mountains_Club is ERC721Enumerable, ERC721Royalty, DefaultOperatorFilterer, Ownable {
    using Counters for Counters.Counter;

    uint256 maxSupply = 542;

    string public baseTokenURI =
        "ipfs://QmNyDfNaWYAF8EJwi53HfkThxDkXUVRXj5pTZWgFph2z4j/";

    bytes32 public merkleRootOfWl1;
    bytes32 public merkleRootOfWl2;

    uint256 public priceForWl1 = 0 ether;
    uint256 public priceForWl2 = 0.02 ether;
    uint256 public priceForPublic = 0.05 ether;

    uint96 public feeNum = 400; //  4%

    bool public allowlistMintOpen1 = false;
    bool public allowlistMintOpen2 = false;
    bool public publicMintOpen = false;

    address public walletToCollectRoyalty =
        0x2D6E7bA52EF8f899E578D9cfeF9218633AaDE8E7;

    //The addresses mentionned in mapping are allowed to mint with the bool functionnality || AllowListMint1 (3 legendaries NFTs)
    mapping(address => bool) public allowList1;

    //The addresses mentionned in mapping are allowed to mint with the bool functionnality || AllowListMint2 (250 legendaries NFTs)
    mapping(address => bool) public allowList2;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Mountains_Club", "MTNS") {
        _setDefaultRoyalty(walletToCollectRoyalty, feeNum);
    }

    /* -------------- Override the crashing functions ----------- */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setApprovalForAll(address operator, bool approved) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        override(ERC721, IERC721)
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    /* ----------------------------------------------------------- */

    //  Get the base uri of token
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    //  Set the base uri for token
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    //Modify the Mint Windows (Openning or Closing the Mint Process Ability Manually by Owner's Contract with "False" or "True" Variables in the Boolean blankspace)
    function editMintWindows(
        bool _allowlistMintOpen1,
        bool _allowlistMintOpen2,
        bool _publicMintOpen
    ) external onlyOwner {
        allowlistMintOpen1 = _allowlistMintOpen1;
        allowlistMintOpen2 = _allowlistMintOpen2;
        publicMintOpen = _publicMintOpen;
    }

    //  Airdrop mint
    function allowlistmint1(bytes32[] calldata _merkleProof, uint8 amount)
        public
        payable
        callerIsUser
    {
        bytes32 leaf;

        require(amount == 1, "You can mint a NFT at once.");

        require(allowlistMintOpen1, "Legendaries Mint Closed");

        // require(allowList1[msg.sender], "You are not on the Allow List");

        leaf = keccak256(abi.encodePacked(msg.sender));

        require(
            MerkleProof.verify(_merkleProof, merkleRootOfWl1, leaf),
            "You are not on the Allow List"
        );

        require(msg.value >= priceForWl1, "Not Enough Funds");

        require(totalSupply() < 3, "Legendaries are Sold Out !");

        require(balanceOf(msg.sender) <= 1, "Max Mint per wallet reached");

        internalMint();
    }

    //require VIP People (wave2) allowed to mint in private process the first 150 NFTs
    function allowlistmint2(bytes32[] calldata _merkleProof, uint8 amount)
        public
        payable
        callerIsUser
    {
        bytes32 leaf;

        require(
            amount >= 1 && amount <= 2,
            "You can mint 1 NFT min, 2 NFTs max at once."
        );

        require(allowlistMintOpen2, "Allowlist Mint 2 Closed");

        // require(allowList2[msg.sender], "You are not on the Allow List");

        leaf = keccak256(abi.encodePacked(msg.sender));

        require(
            MerkleProof.verify(_merkleProof, merkleRootOfWl2, leaf),
            "You are not on the Allow List"
        );

        require(msg.value >= priceForWl2 * amount, "Not Enough Funds");

        require(totalSupply() < 250, "We Sold Out!");

        require(balanceOf(msg.sender) <= 2, "Max Mint per wallet reached");

        for (uint8 i = 0; i < amount; i++) {
            internalMint();
        }
    }

    //All People are allowed to mint the latest NFTs until 555th

    function publicMint(uint8 amount) public payable callerIsUser {
        require(publicMintOpen, "Public Mint Closed");

        require(
            amount <= 4 && amount >= 1,
            "You can mint 1 NFT min, 4 NFTs max at once."
        );

        require(msg.value >= priceForPublic * amount, "Not Enough Funds");

        require(totalSupply() < maxSupply, "We Sold Out!");

        require(balanceOf(msg.sender) <= 4, "Max Mint per wallet reached");

        for (uint8 i = 0; i < amount; i++) {
            internalMint();
        }
    }

    function internalMint() internal {
        uint256 tokenId = _tokenIdCounter.current() + 13;

        _tokenIdCounter.increment();

        _safeMint(msg.sender, tokenId);
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");

        _;
    }

    //To which address the funds are directed -> Contract Owner (proprietary)

    function withdraw(address _addr) external onlyOwner {
        //get the balance of the contract

        uint256 balance = address(this).balance;

        payable(_addr).transfer(balance);
    }

    //Only the Contract Proprietary has the ability to add addresses able to Mint during Wave1 (3 NFTs)

    function setAllowList1(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            allowList1[addresses[i]] = true;
        }
    }

    //Only the Contract Proprietary has the ability to add addresses able to Mint during Wave2 (150 NFTs)

    function setAllowList2(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            allowList2[addresses[i]] = true;
        }
    }

    function setMerkleRootOfWl1(bytes32 _whitelistMerkleRoot) public onlyOwner {
        merkleRootOfWl1 = _whitelistMerkleRoot;
    }

    function setMerkleRootOfWl2(bytes32 _whitelistMerkleRoot) public onlyOwner {
        merkleRootOfWl2 = _whitelistMerkleRoot;
    }

    function setWalletToCollectRoyalty(address walletAddress) public onlyOwner {
        walletToCollectRoyalty = walletAddress;
        _setDefaultRoyalty(walletAddress, feeNum);
    }

    function setFeeNum(uint96 _feeNum) public onlyOwner {
        feeNum = _feeNum;
        _setDefaultRoyalty(walletToCollectRoyalty, _feeNum);
    }
}
