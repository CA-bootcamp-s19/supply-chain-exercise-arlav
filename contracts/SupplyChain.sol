/*
    This exercise has been updated to use Solidity version 0.6
    Breaking changes from 0.5 to 0.6 can be found here:
    https://solidity.readthedocs.io/en/v0.6.12/060-breaking-changes.html
*/

pragma solidity >=0.6.0 <0.7.0;

contract SupplyChain {

  /* set owner */
  address owner;

  /* Add a variable called skuCount to track the most recent sku # */

  uint public skuCount;


  /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
     Call this mappings items
  */

  mapping(uint => Item) public items; //maps the SKU to an items


  /* Add a line that creates an enum called State. This should have 4 states
    ForSale
    Sold
    Shipped
    Received
    (declaring them in this order is important for testing)
  */

  enum State {ForSale, Sold, Shipped, Received }

  /* Create a struct named Item.
    Here, add a name, sku, price, state, seller, and buyer
    We've left you to figure out what the appropriate types are,
    if you need help you can ask around :)
    Be sure to add "payable" to addresses that will be handling value transfer
  */

  struct Item {
    string name;
    uint sku;
    uint price;
    State state; //enums are declared with their name as such inside a struct!
    address payable seller; //payable as it will handle vallue transfer
    address payable buyer; //payable as it will handle vallue transfer

  }

  /* Create 4 events with the same name as each possible State (see above)
    Prefix each event with "Log" for clarity, so the forSale event will be called "LogForSale"
    Each event should accept one argument, the sku */


    event LogForSale (uint _sku);
    event LogSold (uint _sku);
    event LogShipped (uint _sku);
    event LogReceived (uint _sku);


/* Create a modifer that checks if the msg.sender is the owner of the contract */

modifier isOwner () { //checks if the msg.sender is the owner of the contract
  require (owner == msg.sender, "You are not the Owner");
  _;
}

modifier verifyCaller (address _address) { // Verify if caller is a buyer or seller
  require (msg.sender == _address, "Incorrect caller");
  _;
}

  modifier paidEnough(uint _price) {
    require(msg.value >= _price, "Insufficient amount");
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }

  /* For each of the following modifiers, use what you learned about modifiers
   to give them functionality. For example, the forSale modifier should require
   that the item with the given sku has the state ForSale.
   Note that the uninitialized Item.State is 0, which is also the index of the ForSale value,
   so checking that Item.State == ForSale is not sufficient to check that an Item is for sale.
   Hint: What item properties will be non-zero when an Item has been added?

   PS: Uncomment the modifier but keep the name for testing purposes!
   */


  modifier forSale (uint sku) {
    require(items[sku].state == State.ForSale, "Item not For Sale");
    _;
  }

  modifier sold (uint sku) {
    require(items[sku].state == State.Sold, "Item Not Sold");
    _;
  }
  modifier shipped (uint sku) {
    require(items[sku].state == State.Shipped, "Item Has Not Shipped");
    _;
  }

  modifier received (uint sku) {
    require(items[sku].state == State.Received, "Item Has Not Been Received");
    _;
  }


  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */
       owner == msg.sender;
       skuCount = 0;
  }

  function addItem(string memory _name, uint _price) public returns(bool){
    emit LogForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount + 1;
    return true;
  }

  /* Add a keyword so the function can be paid.
  This function should transfer money to the seller, (all this happens )
  set the buyer as the person who called this transaction,
  and set the state to Sold. (arlav comment:these three happen within the brackets)!
  Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent.(Arlav comment: These three are modifiers called after the function. )
     Remember to call the event associated with this function!*/

  function buyItem(uint sku) public payable forSale(_sku) paidEnough(items[_sku].price) checkValue(_sku) {
      emit LogSold(_sku);
      items[_sku].seller.transfer(items[_sku].price); // Transfer money to the seller
      items[_sku].buyer = msg.sender; // Set the buyer as the person who called this transaction
      items[_sku].state = State.Sold; // Set the state to Sold.
  }

  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller(arlav comment: this takes place after function declaration).
   Change the state of the item to shipped. Remember to call the event associated with this function!
   (arlav comments: this takes place within the brackets)
   */
  function shipItem(uint sku) public sold(_sku) verifyCaller(items[_sku].seller) {
    emit LogShipped(_sku);
    items[_sku].state = State.Shipped; // Change the state of the item to shipped.

  }


  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
  function receiveItem(uint sku)
    public shipped(_sku) verifyCaller(items[_sku].buyer)
  {
    emit LogReceived(_sku);
    items[_sku].state = State.Received; //change state to received.
  }

  /* We have these functions completed so we can run tests, just ignore it :) */

  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  } 

}
