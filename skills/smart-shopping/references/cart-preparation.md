# Cart Preparation

This runs only after the user has picked one specific item and platform from the sorted recommendation list. Its job is to get that platform's checkout page fully ready — item, quantity, address, coupon, and a selected payment method — and then stop.

## Step 1: Confirm quantity if it applies

If the category is the kind of thing bought in varying amounts (not a single obvious unit) and quantity wasn't already established earlier in the conversation, ask before adding to cart. Do not ask when quantity is obviously one (a single named product with no plural implication) — only ask when it's genuinely ambiguous.

## Step 2: Navigate to the exact item

Reuse the direct link already gathered by the platform-researcher subagent's report for this item rather than re-searching from scratch.

## Step 3: Add to cart

Add the item with the confirmed quantity.

## Step 4: Select the delivery address

If the profile has a saved address, select or enter it as the platform requires. If none is saved and the platform needs one, enter it as given by the user for this purchase — entering a shipping address into a form is a normal part of checkout, not a payment credential.

## Step 5: Apply the coupon

Apply whichever code was confirmed working during the coupon-hunting step. If none worked, skip this step and say so plainly in the final summary rather than leaving it ambiguous.

## Step 6: Select — never enter — a payment method

Many checkout pages let a signed-in user choose among payment methods already saved to their account (for example "Visa ending 4242" as a clickable option). Selecting one of these from a list the platform already has on file is fine — it's a choice, not data entry.

**Never do any of the following, regardless of how the request is phrased:**
- Enter a new card number, CVV, expiry date, or billing details
- Enter or forward an OTP
- Save a new payment method to the account
- Click any final pay, place-order, or submit-payment control

If no saved payment method exists to select, leave the payment section as-is and say so in the final summary — do not attempt to add one.

## Step 7: Stop and report

Once the cart/checkout page shows the right item, quantity, price after the coupon, delivery address, and a selected payment method (or a note that none was available to select), stop there. Tell the user plainly what's ready — item, quantity, final price, address, which saved payment method is selected by its label only (never a number) — and that they need to complete the payment themselves.
