// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract HeroContract is Ownable, ERC721URIStorage   {

constructor() public ERC721("Good Fellaz NFT", "GFN") {}
  using SafeMath for uint256;

  event newHero(uint heroId, string name, uint dna, uint patk, uint readyTime);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 7 days;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  struct Hero {
    string name;
    uint dna;
    uint patk;
    uint readyTime;
  }

  Hero[] public heroes;

  mapping (uint => address) public heroToOwner;
  mapping (address => uint) ownerHeroCount;
  mapping (uint => address) heroApprovals;

// mint hero, push it to arrays

  function _createHero(string memory _name, uint _dna, uint _patk, uint _readyTime) internal {
    heroes.push(Hero(_name, _dna, 1, uint32(block.timestamp + cooldownTime)));
    uint id = heroes.length - 1;
    heroToOwner[id] = msg.sender;
    ownerHeroCount[msg.sender]++;
    emit newHero(id, _name, _dna, _patk, _readyTime);
    string memory tokenURI1 = "https://gateway.pinata.cloud/ipfs/QmQ5Dq4BuJvbv8HhAw69PSmMht9vM7xYs7EzzSWkCEkc2T";
    mintNFT(msg.sender, tokenURI1);
  
    //need to add minting function
  }

    function mintNFT(address recipient, string memory tokenURI) public returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
    // get a string and input random dna - unsecure method, use oracle before going to production
  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

    //function will first generate random dna(above function) using the name parameter than will create hero using the random dna created
    //need to add more randomness fom each of the stats
  function createRandomHero(string memory _name) public payable{
    require(ownerHeroCount[msg.sender] < 5);
    //require(msg.value > 0.3 ether);
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 100;
    uint randPatk = 100; //should add randomness
    _createHero(_name, randDna, randPatk, uint32(block.timestamp + cooldownTime));
  }


//add for so this can get more than one value
    modifier onlyOwnerOf(uint _heroId) {
    require(msg.sender == heroToOwner[_heroId]);
    _;
  }

    function _triggerCooldown(Hero storage _hero) internal {
    _hero.readyTime = uint32(block.timestamp + cooldownTime);
  }
    function _isReady(Hero storage _hero) internal view returns (bool) {
      return (_hero.readyTime <= block.timestamp);
  }

    function feedAndMultiply(uint _firstHeroId, uint _secondHeroId , string memory _species) internal {
    require(msg.sender == heroToOwner[_firstHeroId]);
    require(msg.sender == heroToOwner[_secondHeroId]);
    Hero storage myFirsthero = heroes[_firstHeroId];
    require(_isReady(myFirsthero));
    Hero storage mySecondhero = heroes[_secondHeroId];
    require(_isReady(mySecondhero));
    uint newDna = (myFirsthero.dna + mySecondhero.dna) / 2;
    _createHero("NoName", newDna, 100, uint32(block.timestamp + cooldownTime));
    _triggerCooldown(myFirsthero);
    _triggerCooldown(mySecondhero);
  }

//Withdraw Function - Really Important

    // function withdraw() internal onlyOwner {
    // owner.transfer(address(this).balance);
    // }

    function getHeroesByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerHeroCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < heroes.length; i++) {
      if (heroToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }


// check why override

   function balanceOf(address _owner) public view override returns (uint256 _balance) {
    return ownerHeroCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public view override returns (address _owner) {
    return heroToOwner[_tokenId];
  }

  // function _transfer(address _from, address _to, uint256 _tokenId) private override {
  //   ownerHeroCount[_to] = ownerHeroCount[_to].add(1);
  //   ownerHeroCount[msg.sender] = ownerHeroCount[msg.sender].sub(1);
  //   heroToOwner[_tokenId] = _to;
  //   transfer(_from, _to, _tokenId);
  // }

  // function transfer(address _from, address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
  //   _transfer(msg.sender, _to, _tokenId);
  // }

  // function approve(address _from, address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
  //   heroApprovals[_tokenId] = _to;
  //   approve(msg.sender, _to, _tokenId);
  // }

}