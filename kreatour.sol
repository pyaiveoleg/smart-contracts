pragma solidity ^0.8.11;
  
  contract Contract {
    uint public price;
    address payable public seller;
    address payable public buyer;

    enum State{Created, Processing, Inactive}
    State public state; 

    constructor () payable{
      seller = payable(msg.sender);
      price = msg.value;
    }

    ///The function cannot be called at the current state.  
    error InvalidState();
    /// only the buyer can call this function
    error OnlyBuyer();
     /// only the seller can call this function
    error OnlySeller();

    modifier inState(State state_){
      if (state !=state_) {
        revert InvalidState();
      }
      _;
      
    }

    modifier onlyBuyer() {
      if (msg.sender != buyer){
        revert OnlyBuyer();
      }
      _;
    }
    
    modifier onlySeller() {
      if (msg.sender != seller){
        revert OnlySeller();
      }
      _;
    }

    function confirmPurchase() external inState (State.Created) payable{
      require(msg.value ==(2 * price), "Please send in 2x purchase amount");
      buyer = payable(msg.sender);
      state = State.Processing;
    }

    function confirmReceived() external onlyBuyer inState(State.Processing) {
    ///state = State.Release;
      buyer.transfer(price);
      state = State.Inactive;
      seller.transfer(2 * price);
    }

    ///function paySeller() external onlySeller inState(State.Release) {
    /// state = State.Inactive;
    /// seller.transfer(uint256(2 * price));
    ///}

    function abort() external onlySeller inState(State.Created) {
      state = State.Inactive;
      seller.transfer(address(this).balance);
    }

  }
