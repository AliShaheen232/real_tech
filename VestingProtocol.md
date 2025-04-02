Vesting Portal: aka Loyalty Freeze

TOP LEFT <- <- <-
User Information: Example
Available Tokens 5000
Locked Tokens 1000
Total Tokens 6000
Current Price $5.00
Balance Total $30,000.00

Detail: User’s wallet balance is 5000 and the locked amount in the vesting portal is 1000 tokens. Actually User’s balance is 6000 REAL tokens. We can make a nodeJS script for this total tokens calculation. This script will check the user's account balance and receipt tokens balance. Script details can be shown on the Frontend side.

---

TOP RIGHT-> -> ->
Platform Information:
Available Total 600,000 (available to LOCK)
Locked Member Total 1,900,000 (already locked)
Platform Member Total 2,500,000 (available+locked)

Circulating Supply 19,100,000 (Total Supply -minus Locked)
Total Supply 21,000,000
Max Supply 100,000,000 (remaining token for DAO to decide)

Detail: We can make a nodeJS script for this calculation. Circulating supply, total locked Member, total supply and available total. Script details can be shown on the Frontend side.

---

BOTTOM LEFT <- <- <-
Actions:
Amount to Lock/Unlock 1-MAX (note: add MAX button)
Duration Total 1-120 Months
Unlock Events 1-10
Unlock Dates: Our system automatically displays the dates.
Note: Months/Events=months per event. (MPE)
Note: Unlock date is every MPE
Buttons Lock / Unlock / Cancel / Clear
Unlock Schedule All user’s unlock dates with:
Unlock date, locked, unlocked, original Vesting total, original
vesting date, withdrawn total
\*\*Also Unlock buttons. The website needs to automatically calculate the total qualifying amount available to unlock. Then the user can select "Max" or enter the desired amount.

Detail: In vesting contract we can manage this point, While in, vesting the tokens user needs to mention the Duration to lock the tokens, Select the unlock events. Elaborate “Amount to Lock/Unlock”.

---

BOTTOM RIGHT -> -> ->
Comment Section for users to add notes into the transaction.  
These notes will be logged into our backend.

Terms & Conditions Legal Notice saying we are not responsible for locked tokens
We cannot unlock tokens. We are not in control of ethereum
Warnings:
Ethereum transactions are irreversible. DO NOT LOCK TOKENS WITHOUT PROPER CONSIDERATION. WE CANNOT RELEASE TOKEN ONCE YOU HAVE LOCKED INTO A VESTING CONTRACT..
KNOW YOUR REASON FOR VESTING YOUR TOKENS. DO NOT LOCK TOKENS WITHOUT UNDERSTANDING WHY.

Detail: In the vesting contract we can have a MEMO field in the vesting method, where users can add memo text for future use or for just transaction memory.
