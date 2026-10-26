// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    enum Stage { Manufactured, WithDistributor, WithRetailer, Sold }

    struct Product {
        uint id;
        string name;
        address owner;
        Stage stage;
    }

    address public manufacturer;
    uint public productCount;
    mapping(uint => Product) public products;

    event ProductUpdated(uint id, Stage stage, address by, uint time);

    constructor() {
        manufacturer = msg.sender;   // deployer is the manufacturer
    }

    function addProduct(string memory _name) public {
        require(msg.sender == manufacturer, "Only manufacturer can add");
        productCount++;
        products[productCount] = Product(productCount, _name, msg.sender, Stage.Manufactured);
        emit ProductUpdated(productCount, Stage.Manufactured, msg.sender, block.timestamp);
    }

    function transferProduct(uint _id, address _to) public {
        Product storage p = products[_id];
        require(p.id != 0, "Product does not exist");
        require(msg.sender == p.owner, "Only current owner can transfer");
        require(p.stage != Stage.Sold, "Product already sold");

        p.owner = _to;
        p.stage = Stage(uint(p.stage) + 1);   // move to next stage
        emit ProductUpdated(_id, p.stage, msg.sender, block.timestamp);
    }

    function getProduct(uint _id) public view returns (string memory, address, Stage) {
        Product memory p = products[_id];
        return (p.name, p.owner, p.stage);
    }
}
