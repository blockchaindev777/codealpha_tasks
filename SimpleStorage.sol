// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleStorage
/// @notice Stores a single integer that can be incremented and decremented by 1.
contract SimpleStorage {
    // Public state variable: Solidity auto-generates a getter `value()`.
    int256 public value;

    event ValueChanged(int256 newValue);

    /// @notice Increase the stored value by 1.
    function increment() public {
        value += 1;
        emit ValueChanged(value);
    }

    /// @notice Decrease the stored value by 1.
    function decrement() public {
        value -= 1;
        emit ValueChanged(value);
    }
}
