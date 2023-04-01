// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MintGyuminToken.sol";

contract SaleGyuminToken {
    MintGyuminToken public mintGyuminTokenAddress;

    constructor(address _mintGyuminTokenAddress) {
        mintGyuminTokenAddress = MintGyuminToken(_mintGyuminTokenAddress);
    }

    mapping(uint256 => uint256) public gyuminTokenPrices; //가격 매핑 TokenId입력시 가격이 나오게

    uint256[] public onSaleGyuminTokenArray; //View에서 현재 등록중인 토큰을 보여줄 때 필요한 배열

    function setForSaleGyuminToken(uint _gyuminTokenId, uint256 _price) public{
        address gyuminTokenOwner = mintGyuminTokenAddress.ownerOf(_gyuminTokenId);

        require(gyuminTokenOwner == msg.sender, "Caller is not gyumin token owner."); //토큰 주인이 컨트랙실행자와 같은지 (토큰주인확인)
        require(_price > 0, "Price is zero or lower."); //가격 확인 0보다 작은 가격으로 판매등록 못함 (공짜로 팔면 안됨)
        require(gyuminTokenPrices[_gyuminTokenId] == 0, "This gyumin token is already on sale."); //가격이 0원이 아니면 값이 이미 있다는것 => 판매등록이 이미 됐다는것

        //토큰 주인이 판매 계약에 (지금현재 계약:SaleGyuminToken) 판매 권한을 넘겼는지 확인하는 함수 boolean값으로 나옴
        require(mintGyuminTokenAddress.isApprovedForAll(gyuminTokenOwner, address(this)), "Gyumin Token owner did not approve token.");   //address(this)--> 지금 계약 주소
    
        gyuminTokenPrices[_gyuminTokenId] = _price; 

        onSaleGyuminTokenArray.push(_gyuminTokenId); //상품등록 완료됐으면 배열에 푸쉬해줌
    }

    function purchaseGyuminToken(uint256 _gyuminTokenId) public payable {  //payable키워드가 있어야 가상화폐를 받을 수 있음
        uint256 price = gyuminTokenPrices[_gyuminTokenId];
        address gyuminTokenOwner = mintGyuminTokenAddress.ownerOf(_gyuminTokenId);
        require(price > 0, "Gyumin token not sale. ");
        require(price <= msg.value, "Caller sent lower than price."); //msg.value => 함수를 실행했을때 실행자가 보내는 화폐의 양
        require(gyuminTokenOwner != msg.sender, "Caller is gyumin token owner"); // 해당 토큰을 파는사람이 사는 함수를 실행하면 예외처리

        payable(gyuminTokenOwner).transfer(msg.value); //토큰 주인한테 화폐 송금
        mintGyuminTokenAddress.safeTransferFrom(gyuminTokenOwner, msg.sender, _gyuminTokenId); // 인수 : 보내는사람, 받는사람, 보내는것 

        gyuminTokenPrices[_gyuminTokenId] = 0;
        
        for(uint256 i = 0; i < onSaleGyuminTokenArray.length; i++) {
            if (gyuminTokenPrices[onSaleGyuminTokenArray[i]] ==0) {
                onSaleGyuminTokenArray[i] = onSaleGyuminTokenArray[onSaleGyuminTokenArray.length - 1];
                onSaleGyuminTokenArray.pop();  
            }
        }
    }

    function getOnSaleGyuminTokenArrayLength() view public returns (uint256) {
        return onSaleGyuminTokenArray.length;
    }
}