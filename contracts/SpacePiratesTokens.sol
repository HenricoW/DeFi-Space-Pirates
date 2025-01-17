// SPDX-License-Identifier: unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ERC1155Custom.sol";

/**
 * @title Space Pirates Tokens Contract
 * @author @Gr3it, @yuripaoloni, @MatteoLeonesi
 * @notice Store all the tokens data and give to other contract permission to implements logic on top of the tokens
 */

contract SpacePiratesTokens is ERC1155Custom, AccessControl {
    /**
     * Tokens' Ids distribution
     *      1 -     99 Projects tokens
     *    100 -    199 Wrapped tokens
     *  1 000 -  9 999 Consumable
     * 10 000 - 19 999 Titles
     * 20 000 - 99 999 Decorations
     */
    uint256 public constant DOUBLOONS = 1;
    uint256 public constant ASTEROIDS = 2;
    uint256 public constant VE_ASTEROIDS = 3;
    uint256 public constant STK_ASTEROIDS = 4;

    // Minting role = keccak256(abi.encodePacked("MINT_ROLE_FOR_ID",id));
    // Burning role = keccak256(abi.encodePacked("BURN_ROLE_FOR_ID",id));
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant CAN_PAUSE_ROLE = keccak256("CAN_PAUSE_ROLE");
    bytes32 public constant CAN_UNPAUSE_ROLE = keccak256("CAN_UNPAUSE_ROLE");
    bytes32 public constant TRANSFERABLE_SETTER_ROLE =
        keccak256("TRANSFERABLE_SETTER_ROLE");

    event Mint(
        address indexed sender,
        uint256 id,
        uint256 amount,
        address indexed to
    );
    event Burn(address indexed sender, uint256 id, uint256 amount);
    event MintBatch(
        address indexed sender,
        uint256[] ids,
        uint256[] amounts,
        address indexed to
    );
    event BurnBatch(address indexed sender, uint256[] ids, uint256[] amounts);
    event GrantRole(bytes32 indexed role, address account);
    event RevokeRole(bytes32 indexed role, address account);
    event GrantMultiRole(bytes32[] indexed roles, address[] accounts);
    event RevokeMultiRole(bytes32[] indexed roles, address[] accounts);
    event RenounceRole(bytes32 indexed role, address account);
    event Pause();
    event Unpause();
    event LockTokenTransfer();
    event UnLockTokenTransfer();
    event UriUpdate(string newUri);

    constructor(string memory uri) ERC1155Custom(uri) {
        _mint(msg.sender, DOUBLOONS, 1000000 * (10**18), "");
        _mint(msg.sender, ASTEROIDS, 100 * (10**18), "");

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Custom, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setURI(string memory newUri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newUri);
        emit UriUpdate(newUri);
    }

    function lockTokenTransfer(uint256 id)
        public
        onlyRole(TRANSFERABLE_SETTER_ROLE)
    {
        _setTrasferBlock(id, true);
        emit LockTokenTransfer();
    }

    function unLockTokenTransfer(uint256 id)
        public
        onlyRole(TRANSFERABLE_SETTER_ROLE)
    {
        _setTrasferBlock(id, false);
        emit UnLockTokenTransfer();
    }

    function pause() public onlyRole(CAN_PAUSE_ROLE) {
        _pause();
        emit Pause();
    }

    function unpause() public onlyRole(CAN_UNPAUSE_ROLE) {
        _unpause();
        emit Unpause();
    }

    function mint(
        address to,
        uint256 amount,
        uint256 id
    ) public onlyRole(keccak256(abi.encodePacked("MINT_ROLE_FOR_ID", id))) {
        _mint(to, id, amount, "");
        emit Mint(msg.sender, id, amount, to);
    }

    function burn(
        address from,
        uint256 amount,
        uint256 id
    ) public onlyRole(keccak256(abi.encodePacked("BURN_ROLE_FOR_ID", id))) {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _burn(from, id, amount);
        emit Burn(from, id, amount);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public {
        for (uint256 i = 0; i < ids.length; ++i) {
            _checkRole(
                keccak256(abi.encodePacked("MINT_ROLE_FOR_ID", ids[i])),
                msg.sender
            );
        }
        _mintBatch(to, ids, amounts, "");
        emit MintBatch(msg.sender, ids, amounts, to);
    }

    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public {
        for (uint256 i = 0; i < ids.length; ++i) {
            _checkRole(
                keccak256(abi.encodePacked("BURN_ROLE_FOR_ID", ids[i])),
                msg.sender
            );
        }
        _burnBatch(from, ids, amounts);
        emit BurnBatch(from, ids, amounts);
    }

    function grantRole(bytes32 role, address account)
        public
        override
        onlyRole(getRoleAdmin(role))
    {
        _grantRole(role, account);
        emit GrantRole(role, account);
    }

    function revokeRole(bytes32 role, address account)
        public
        override
        onlyRole(getRoleAdmin(role))
    {
        _revokeRole(role, account);
        emit RevokeRole(role, account);
    }

    function grantMultiRole(
        bytes32[] calldata roles,
        address[] calldata accounts
    ) public {
        require(
            roles.length == accounts.length,
            "AccessControl: array of different length"
        );
        for (uint256 i = 0; i < roles.length; ++i) {
            _checkRole(getRoleAdmin(roles[i]), msg.sender);
            _grantRole(roles[i], accounts[i]);
        }
        emit GrantMultiRole(roles, accounts);
    }

    function revokeMultiRole(
        bytes32[] calldata roles,
        address[] calldata accounts
    ) public {
        require(
            roles.length == accounts.length,
            "AccessControl: array of different length"
        );
        for (uint256 i = 0; i < roles.length; ++i) {
            _checkRole(getRoleAdmin(roles[i]), msg.sender);
            _revokeRole(roles[i], accounts[i]);
        }
        emit RevokeMultiRole(roles, accounts);
    }
}
