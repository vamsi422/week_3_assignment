use starknet::ContractAddress;

#[starknet::interface]
trait IRewardPointsMechanism<TContractState> {
    fn add_points(ref self:TContractState,address:ContractAddress,add_points:u32);
    fn redeem_points(ref self:TContractState,address:ContractAddress,redeem_points:u32);
    fn transfer_points(ref self:TContractState,from_address:ContractAddress,to_address:ContractAddress,trans_points:u32);
}

#[starknet::contract]
mod RewardPointsMechanism {
    use starknet::event::EventEmitter;
use starknet::storage::{StorageMapReadAccess, StorageMapWriteAccess,Map};
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        account_info: Map<ContractAddress, u32>
    }
    #[event]
    #[derive(Drop,starknet::Event)]
    enum Event {
        AddedPoints:AddedPoints,
        RedeemedPoints:RedeemedPoints,
    }
    #[derive(Drop,starknet::Event)]
    struct AddedPoints{
        // points to be added
        #[key]
        add_points:u32,
    }
    #[derive(Drop,starknet::Event)]
    struct RedeemedPoints{
        // points to be redeemed
        #[key]
        redeem_points:u32,
    }

    #[abi(embed_v0)]
    impl RewardPointsMechanismImpl of super::IRewardPointsMechanism<ContractState> {
        fn add_points(ref self:ContractState,address:ContractAddress,add_points:u32){
            self.account_info.write(address, self.account_info.read(address) + add_points);
            self.emit(AddedPoints{add_points});
        }

        fn redeem_points(ref self:ContractState,address:ContractAddress,redeem_points:u32){
            self.account_info.write(address,self.account_info.read(address) - redeem_points);
            self.emit(RedeemedPoints{redeem_points});

        }
        fn transfer_points(ref self:ContractState,from_address:ContractAddress,to_address:ContractAddress,trans_points:u32){
            if self.account_info.read(from_address) >= trans_points {
                self.account_info.write(from_address, self.account_info.read(from_address) - trans_points);
                self.account_info.write(to_address, self.account_info.read(to_address) + trans_points);
            }
        }
    }
}
