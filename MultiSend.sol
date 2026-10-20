// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title MultiSend
/// @notice Splits the Ether sent with a transaction equally among an array of addresses.
contract MultiSend {
    event Sent(address indexed to, uint256 amount);
    event BatchSent(address indexed sender, uint256 recipients, uint256 amountEach, uint256 refunded);

    bool private locked; // simple reentrancy guard

    /// @notice Send msg.value split equally to every address in `recipients`.
    /// @dev Any remainder from integer division is refunded to the caller.
    function multiSend(address[] calldata recipients) external payable {
        require(!locked, "Reentrancy");
        locked = true;

        uint256 count = recipients.length;
        require(count > 0, "No recipients");
        require(msg.value > 0, "No Ether sent");

        uint256 amountEach = msg.value / count;
        require(amountEach > 0, "Amount too small to split");

        for (uint256 i = 0; i < count; i++) {
            address to = recipients[i];
            require(to != address(0), "Zero address");

            (bool ok, ) = payable(to).call{value: amountEach}("");
            require(ok, "Transfer failed");
            emit Sent(to, amountEach);
        }

        // Refund the dust left over from division (e.g. 10 wei / 3 recipients = 1 wei left)
        uint256 remainder = msg.value - (amountEach * count);
        if (remainder > 0) {
            (bool refunded, ) = payable(msg.sender).call{value: remainder}("");
            require(refunded, "Refund failed");
        }

        emit BatchSent(msg.sender, count, amountEach, remainder);
        locked = false;
    }
}
