# Government DAO





![image-20240212002836876](Images/image-20240212002836876.png)





This project is created as a concept where citizens can directly vote on main issues/areas where they want the government to spend money on.

Right now it does not have all the bells and whistles but something that is to be expanded upon. So there are some things that are arbitrarily decided.

The idea is the main issues like Education, Healthcare, Welfare, Infrastructure etc. are voted by citizens. Each citizen starts with 1000 points which are minted as tokens. they can vote more points on more important issues to them.

There will be a 6 months expiry once an issue is created. 







## Deploying locally and Testing





we create few multiple users for testing:

```
chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx identity list
anonymous
chakravartiICP1 *
citizen1
citizen2
citizen3
default
test1
tester1
```





### Re-install for clean tests

Since we have `stable` variables defined for a clean re-test we install the canisters with re-install options.

```bash
dfx canister install dao --mode=reinstall
dfx canister install token --mode=reinstall


chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister install dao --mode=reinstall
WARNING!
You are about to reinstall the dao canister
This will OVERWRITE all the data and code in the canister.

YOU WILL LOSE ALL DATA IN THE CANISTER.


Do you want to proceed? yes/No
yes
Reinstalling code for canister dao, with canister ID by6od-j4aaa-aaaaa-qaadq-cai
chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister install token --mode=reinstall
WARNING!
You are about to reinstall the token canister
This will OVERWRITE all the data and code in the canister.

YOU WILL LOSE ALL DATA IN THE CANISTER.


Do you want to proceed? yes/No
yes
Reinstalling code for canister token, with canister ID avqkn-guaaa-aaaaa-qaaea-cai
```





### deploy locally



```bash
chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx deploy
Deploying all canisters.
All canisters have already been created.
Building canisters...
WARN: .mops/base@0.10.2/src/Principal.mo:80.20-80.32: warning [M0154], field append is deprecated:
`Array.append` copies its arguments and has linear complexity;

WARN: .mops/base@0.10.2/src/Principal.mo:80.20-80.32: warning [M0154], field append is deprecated:
`Array.append` copies its arguments and has linear complexity;
/home/chakravarti/ICP/MotokoBootcamp/dao-government/src/dao/main.mo:241.72-241.84: warning [M0154], field append is deprecated:
`Array.append` copies its arguments and has linear complexity;

Installing canisters...
Module hash ffe44e05213e8032b6878e0f2eabf0ab0e4617caa630e4ffc2e7fdaa31e23123 is already installed.
Module hash b6dc5303780db1178f28bcfc2500517cc6aac76f89b65ba253c5efadf8a17f82 is already installed.
Deployed canisters.
URLs:
  Backend canister via Candid interface:
    dao: http://127.0.0.1:4943/?canisterId=a3shf-5eaaa-aaaaa-qaafa-cai&id=by6od-j4aaa-aaaaa-qaadq-cai
    token: http://127.0.0.1:4943/?canisterId=a3shf-5eaaa-aaaaa-qaafa-cai&id=avqkn-guaaa-aaaaa-qaaea-cai
```



With this we can also look at the Candid UI for our `dao` canister.

### candid UI for `dao` canister

![image-20240214162637239](Images/image-20240214162637239.png)





### Unit Testing

First we do some negative tests and also some general info etc without really creating any citizen, issue etc  Just as some simple tests



#### Test 1 - Try to create issue w/o being a citizen yet - should Error

First we identify the identity just to document it so we keep track of which identity we are testing as.  

```bash
chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx identity whoami
chakravartiICP1
chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao whoami '()'
(principal "jdckm-usp54-5ulyk-2rvou-5a7iw-3s6fz-fauip-2flue-2hhm6-4hugi-iqe")
```



Now below we see that this results in error.

```bash




dfx canister call dao createIssue '("Education", 100)'

chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao createIssue '("Education", 100)'
(variant { err = "NotDAOCitizen" })





```



#### Test 2 - Check Voting Token info

This will be in inter canister call where the `token` canister is called to get the info.

We get the Token Symbol and Token Name which are:

`DVT - Government Dao Voting Token`

```

chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao getDVTTokenSymbol '()'
("DVT")

chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao getDVTTokenName '()'
("Government Dao Voting Token")






```



#### Test 3 - Check our DAO name and manifesto



```
chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao getDaoName '()'
("A Government DAO")


chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao getManifesto '()'
(
  "Manifesto - Implement government Budget through DAO by citizens direct voting",
)


```







#### Test 4 - Check Voting Token balance w/o registering as Citizen

This will be in inter canister call where the `token` canister is called to get the info.

Since we did not register as citizen yet we will NOT have any balance.



```
chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao getBalance '()'
(0 : nat)


```





#### Test 5 - Register as Citizen

Now we register as Citizen giving our name and Voter ID.

```bash
chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao registerCitizen '(record { name="Rafael Nadal"; voterId="VoterId 123" } )'
(variant { ok })
```



#### Test 6 - Check Citizen records and balance

Now since we became citizen we 1000 points to vote for issues.

We check all citizens with function - `getAllCitizens`

```
chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao getBalance '()'
(1_000 : nat)

chakravarti@chakravarti-Latitude-7280:~/ICP/MotokoBootcamp/dao-government$ dfx canister call dao getAllCitizens '()'
(vec { record { name = "Rafael Nadal"; voterId = "VoterId 123" } })

```















