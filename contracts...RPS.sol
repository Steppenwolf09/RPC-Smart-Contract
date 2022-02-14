// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.19;

contract RockPaperScissors {
  event GameCreated(address creator, uint gameNumber, uint bet);
  event GameStarted(address[2] players, uint gameNumber);
  event GameComplete(address winner, uint gameNumber);
  
  uint256 globalGameNumber = 0;
  struct Game {
    address gameCreator;
    address secondPlayer;
    uint24 firstPlayerMove;
    uint24 secondPlayerMove;
    uint256 bet;
    uint256 gameN;
    bool enable;
    bool finished;
    bool secondPlayerPayed;
  }
  mapping(uint256 => Game) private GameByUser;

  function createGame(address payable participant) payable public {
    require(GameByUser[globalGameNumber].finished == false);
    require (msg.value > 0);
    globalGameNumber += 1;
    GameByUser[globalGameNumber].gameCreator = msg.sender;
    GameByUser[globalGameNumber].secondPlayer = participant;
    GameByUser[globalGameNumber].bet = msg.value;
    GameByUser[globalGameNumber].firstPlayerMove = 0;
    GameByUser[globalGameNumber].secondPlayerMove = 0;
    GameByUser[globalGameNumber].secondPlayerPayed = false;
    GameByUser[globalGameNumber].enable = false;
    GameByUser[globalGameNumber].finished = false;
    emit GameCreated(msg.sender, globalGameNumber, msg.value);
  }

  function joinGame(uint gameNumber) payable public {
    require(GameByUser[globalGameNumber].finished == false);
    require(GameByUser[gameNumber].secondPlayerPayed != true);
    require(GameByUser[gameNumber].secondPlayer == msg.sender);
    require(msg.value >= GameByUser[gameNumber].bet);
    if (GameByUser[gameNumber].bet < msg.value){
       uint256 change = msg.value - GameByUser[gameNumber].bet;
       payable (msg.sender).transfer(change);
    }
    GameByUser[gameNumber].secondPlayerPayed = true;
    GameByUser[gameNumber].enable = true; 
    emit GameStarted([GameByUser[gameNumber].gameCreator, msg.sender], gameNumber);
  }

  function makeMove(uint gameNumber, uint24 moveNumber) public { 
    require(GameByUser[globalGameNumber].finished == false);
    require(GameByUser[gameNumber].enable == true);
    require ((msg.sender == GameByUser[gameNumber].gameCreator) || (msg.sender == GameByUser[gameNumber].secondPlayer));
    require ((moveNumber <= 3) && (moveNumber > 0));
    if (msg.sender == GameByUser[gameNumber].gameCreator){
        GameByUser[gameNumber].firstPlayerMove = moveNumber;
    }
    if (msg.sender == GameByUser[gameNumber].secondPlayer){
        GameByUser[gameNumber].secondPlayerMove = moveNumber;
    }
    if ((GameByUser[gameNumber].firstPlayerMove != 0) && (GameByUser[gameNumber].secondPlayerMove != 0)){
        uint result = battle(GameByUser[gameNumber].firstPlayerMove, GameByUser[gameNumber].secondPlayerMove);
        if (result == 0){
            emit GameComplete(address(0), gameNumber);
        }
        if (result == 1){
            emit GameComplete(GameByUser[gameNumber].gameCreator, gameNumber);
        }
        if (result == 2){
            GameByUser[gameNumber].enable = false;
            emit GameComplete(GameByUser[gameNumber].secondPlayer, gameNumber);
        }
    }
  }
  function battle(uint24 first, uint24 second) internal pure returns (uint24) {
    if (first == second){
        return uint24(0);
    }
    if (first == 1){
        if(second == 2){
            return uint24(2);
        }
        if(second == 3){
            return uint24(1);
        }
    }
    if (first == 2){
        if(second == 1){
            return uint24(1);
        }
        if(second == 3){
            return uint24(2);
        }
    }
    if (first == 3){
        if(second == 1){
            return uint24(2);
        }
        if(second == 2){
            return uint24(1);
        }
    }
    return 4;
  }
}