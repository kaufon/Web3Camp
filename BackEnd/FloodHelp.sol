//// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

struct Request{
  uint id;
  address author;
  string title;
  string description;
  string contact;
  uint timestamp;
  uint goal; 
  uint balance;
  bool open;
}
  
  

contract FloodHelp {
  
  uint public lastID = 0;
  mapping (uint => Request) public requests;
  
  function openRequest(string memory title,string memory description,string memory contact,uint goal) public {
    lastID++;
    requests[lastID] =Request({

      id: lastID,
      title: title,
      description:description,
      contact:contact,
      goal:goal,
      balance: 0,
      open: true,
      timestamp: block.timestamp,
      author: msg.sender
    }); 
  }
  function closeRequest(uint id) public {
     address author = requests[id].author;
     uint balance = requests[id].balance;
     uint goal = requests[id].goal;
     require(requests[id].open == true && (msg.sender == author || balance >= goal),"You cant close this request");
     
     requests[id].open = false;

     if (balance > 0) {
        requests[id].balance = 0;
        payable(author).transfer(balance);
     } 

  }
  function donate(uint id) public payable  {
    requests[id].balance += msg.value;
    if (requests[id].balance >= requests[id].goal) {
      closeRequest(id);
    } 
  }

  function getOpenRequests(uint startId,uint quantity) public view returns (Request[] memory){
    Request[] memory result = new Request[](quantity);
    uint id = startId;
    uint count = 0;
    do{
      if (requests[id].open) {
        result[count] = requests[id];
        count++;
      } 
      id++;  
    }
   while(count < quantity && id <= lastID); 
   return result;
  }
}
