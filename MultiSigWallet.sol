//Creator: Alfie Lloyd

pragma solidity 0.7.5;


pragma abicoder v2;


contract msWallet{
    
    address contractOwner;
    address[] owners;
    uint minApprovals;
    txReq[] txRequestLog;

    
    modifier onlyOwners(){
        bool isOwner = false;
        for(uint i=0;i<3;i++){
            if (owners[i] == msg.sender){
                isOwner = true;
            }
        }
        require(isOwner == true,"Not authourized for action");
        _;
    }
      

    
    constructor(address[] memory _owners, uint _minApprovals){
        contractOwner = msg.sender;
        owners = _owners;
        owners.push(msg.sender);
        minApprovals = _minApprovals;
    }
   
    struct txReq{
        address requestor;
        uint amount;
        address payable recipient;
        uint approvals;
        bool approved;
    }
   
    //empty function that allows anyone to deposit funds into the contract 
     function deposit() public payable returns (uint){
    }
   
    //returns the overall balance of the multi-Sig wallet 
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
   
   //returns the address of the person who deployed the contract 
    function getOwner() public view returns(address){
        return contractOwner;
    }
    //creates a txReq struct, details of who made req/the recipient/the amount to send
    //requires that the request is less than or equal to the amount in the wallet
    function _txRequest(uint _amount,address payable _recipient) public onlyOwners{
        
        require(_amount<=address(this).balance,"Insufficient funds");
        txReq memory newRequest= txReq(msg.sender,_amount,_recipient,1,false);
        //txRequest = newRequest;
        //txRequestLog[newRequest] = 1;
        txRequestLog.push(newRequest);
    }
   //allows any owner to approve a request within the request log
   //doesn't allow an owner to approve they're own requests, neither approve the same request more than once
    function approveRequest(uint _idx) public onlyOwners{
        require(txRequestLog[_idx].requestor != msg.sender,"You can't approve your own request"); //make sure the person who's approving isn't the requstor of
        //the transaction
        
        //don't allow more approvals if the request reaches max approvals 
        require(txRequestLog[_idx].approved == false, "txRequest has already been approved");

        txRequestLog[_idx].approvals +=1;
        if (txRequestLog[_idx].approvals >=minApprovals){
            txRequestLog[_idx].approved = true;
            txRequestLog[_idx].recipient.transfer(txRequestLog[_idx].amount);
        }
    }
   
 
   //function to display all requests
    function getRequests(uint _idx) public view returns(txReq memory){
        //find out how you can return multiple values as I try to return the txReq attributes in the txRequestLog[]
        //and it doesn't like it even if I set each value to it's own variable and reeturn them together
        return txRequestLog[_idx];
    }
   
   //getter function to show all the owners of the contract 
    function getOwners() public view returns(address[] memory){
        //find out how you can return multiple values as I try to return the txReq attributes in the txRequestLog[]
        //and it doesn't like it even if I set each value to it's own variable and reeturn them together
        return owners;
    }
}