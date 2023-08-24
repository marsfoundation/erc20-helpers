// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

interface IERC20Like {

    function approve(address spender_, uint256 amount_) external returns (bool success_);

    function transfer(address recipient_, uint256 amount_) external returns (bool success_);

    function transferFrom(address owner_, address recipient_, uint256 amount_)
        external returns (bool success_);

}

/**
 * @title Small Library to standardize erc20 token interactions.
 */
library ERC20Helper {

    /**********************************************************************************************/
    /*** Internal Functions                                                                     ***/
    /**********************************************************************************************/

    function safeTransfer(address token_, address to_, uint256 amount_)
        internal returns (bool success_)
    {
        success_
            = _call(token_, abi.encodeWithSelector(IERC20Like.transfer.selector, to_, amount_));
    }

    function safeTransferFrom(address token_, address from_, address to_, uint256 amount_)
        internal returns (bool success_)
    {
        success_ = _call(
            token_,
            abi.encodeWithSelector(IERC20Like.transferFrom.selector, from_, to_, amount_)
        );
    }

    function safeApprove(address token_, address spender_, uint256 amount_)
        internal returns (bool success_)
    {
        // If setting approval to zero fails, return false.
        if (!_call(
            token_, abi.encodeWithSelector(IERC20Like.approve.selector, spender_, uint256(0)))
        ) return false;

        // If `amount_` is zero, return true as the previous step already did this.
        if (amount_ == uint256(0)) return true;

        // Return the result of setting the approval to `amount_`.
        success_
            = _call(token_, abi.encodeWithSelector(IERC20Like.approve.selector, spender_, amount_));
    }

    function _call(address token_, bytes memory data_) private returns (bool success_) {
        if (token_.code.length == uint256(0)) return false;

        bytes memory returnData;
        ( success_, returnData ) = token_.call(data_);

        return success_ && (returnData.length == uint256(0) || abi.decode(returnData, (bool)));
    }

}
