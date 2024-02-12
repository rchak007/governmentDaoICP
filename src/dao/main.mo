import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Types "types";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Array "mo:base/Array";

import tokenCanister "canister:token";

actor DAO {


        type Result<A, B> = Result.Result<A, B>;
        // type Member = Types.Member;
        type Citizen = Types.Citizen;
        // type ProposalContent = Types.ProposalContent;
        // type ProposalId = Types.ProposalId;
        // type Proposal = Types.Proposal;
        type Issue = Types.Issue;
        type IssueId = Types.IssueId;
        type Vote = Types.Vote;
        type HttpRequest = Types.HttpRequest;
        type HttpResponse = Types.HttpResponse;

        stable let canisterIdWebpage : Principal = Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai"); // TODO: Change this to the ID of your webpage canister
        // stable var manifesto = "Your manifesto";
        // stable let name = "Your DAO";
        stable var manifesto = "Implement government Budget through DAO";
        stable let name = "A Government DAO";
        stable var goals = [];
        stable var issueID: Nat = 0;

        let citizens : HashMap.HashMap<Principal, Citizen> = HashMap.HashMap<Principal, Citizen>(0, Principal.equal, Principal.hash);


        // Define an async function to call tokenSymbol
        public func getMBTTokenSymbol() : async Text {
                let tokenMBTSymbol = await tokenCanister.tokenSymbol();
                return tokenMBTSymbol;
        };

        // let tokenCan = await tokenCanister.tokenSymbol(); 

        // Returns the name of the DAO
        public query func getName() : async Text {
                // return "Not implemented";
                return name;
        };

        // Returns the manifesto of the DAO
        public query func getManifesto() : async Text {
                // return "Not implemented";
                return manifesto;
        };

        // Returns the goals of the DAO
        // public query func getGoals() : async [Text] {
        //         // return [];
        //         return goals;
        // };

        // Register a new citizen in the DAO with the given name, voter and principal of the caller
        // Airdrop 50 MBC tokens to the new citizen to vote
        // Returns an error if the citizen already exists
        public shared ({ caller }) func registerCitizen(citizen : Citizen) : async Result<(), Text> {
                switch (citizens.get(caller)) {
                        case (?citizen) {
                                return #err("Already citizen");
                        };
                        case (null) {
                                citizens.put(caller, citizen);
                                let mbtTokens = await tokenCanister.mint(caller, 1000);
                                return #ok(());
                        };
                };                
                // return #err("Not implemented");
        };

        private func _getCitizen(p : Principal) : Result<Citizen, Text> {
                switch (citizens.get(p)) {
                        case (?citizen) {
                                return #ok(citizen);
                        };
                        case (null) {
                                return #err("Not a citizen");
                        };
                };
        };
        // Get the member with the given principal
        // Returns an error if the member does not exist
        // public query func getMember(p : Principal) : async Result<Member, Text> {
        //         return #err("Not implemented");
        // };

        // Graduate the student with the given principal
        // Returns an error if the student does not exist or is not a student
        // Returns an error if the caller is not a mentor
        // public shared ({ caller }) func graduate(student : Principal) : async Result<(), Text> {
        //         return #err("Not implemented");
        // };


        let issues = HashMap.HashMap<IssueId, Issue>(0, Nat64.equal, Nat64.toNat32);
        
        // Create a new Issue and returns its id
        // Returns an error if the caller is not a mentor or doesn't own at least 1 MBC token
        public shared ({ caller }) func createIssue(content : Text, points: Nat) : async Result<Nat64, Text> {
                // Check if caller is Dao Citizen
                let daoCitizen = _getCitizen(caller: Principal);
                switch (daoCitizen) {
                        case (#ok(citizen)) {
                                // now create the issue with their points added
                                // need to check if Citizen has the balance
                                let myBalance = await tokenCanister.balanceOf(caller);
                                if (points < 1) {
                                        return #err("VotePointsNotPositive");
                                };
                                if (myBalance >= points) {
                                        // Average number of days in a month * number of months
                                        let sixMonthsInSeconds : Nat = (30.44 * 24 * 60 * 60 * 6);
                                        var expiry : Time.Time = Time.now();
                                        let currentTime = Time.now();
                                        expiry := (currentTime + sixMonthsInNanoseconds);
                                        // identify who voted as we are transparent
                                        let vote1 : Vote = {
                                                citizen = caller;
                                                points = points;
                                        };                                        
                                        let issue = {
                                                issueId : Nat64 = issueID; 
                                                content : Text = content;
                                                creator : Principal = caller;
                                                created : Time.Time = currentTime;
                                                expiry : Time.Time = expiry;
                                                votes : [Vote] = [vote1];
                                                voteScore : Int = points;
                                                // status : Types.IssueStatus = propStatus;
                                        };
                                        issues.put(issueID, issues);
                                        // burn the points citizen used on this issue
                                        let mbtTokens = await tokenCanister.burn(caller, points);
                                        return #ok(issueID);
                                } else {
                                        return #err("Not enough points")
                                };
                        };
                        case (#err(error)) {
                                return #err("NotDAOCitizen");
                        };
                };  // end switch daoCitizen
                // return #err("Not implemented");
        };

        // Get the proposal with the given id
        // Returns an error if the proposal does not exist
        public query func getProposal(id : IssueId) : async Result<Issue, Text> {
            switch(issues.get(id)) {
              case(null) { return #err("no issue with that id") };
              case(?issue) { return #ok(issue);  };   //return #ok(issueID);
            };
        };
                


        // Returns all the proposals
        public query func getAllIssues() : async [Issue] {
                return Iter.toArray(issues.vals());
        };

        // Vote for the given Issue
        // Returns an error if the proposal does not exist or the member is not allowed to vote
        public shared ({ caller }) func voteIssue(issueId : IssueId, points : Nat) : async Result<(Nat64), Text> {
                // Check if caller is Dao Citizen
                let daoCitizen = _getCitizen(caller: Principal);
                switch (daoCitizen) {
                        case (#ok(citizen)) {
                                // now create the issue with their points added
                                // need to check if Citizen has the balance
                                let myBalance = await tokenCanister.balanceOf(caller);
                                if (points < 1) {
                                        return #err("VotePointsNotPositive");
                                };
                                if (myBalance >= points) {
                                        // need to check the IssueID exists first
                                        switch (issues.get(issueId)) {
                                                case(null) { return #err("IssueNotFound");};
                                                case(?issue) {
                                                        // Then check its not expired
                                                        let currentTime = Time.now();
                                                        let issueExpiry = issue.expiry;
                                                        if (currentTime > issueExpiry) {
                                                            return #err("IssueExpired");
                                                        };
                                                        // we actually dont care they already voted since its based on points. so they could basically add more.
                                                        // identify who voted as we are transparent
                                                        let vote1 : Vote = {
                                                            citizen = caller;
                                                            points = points;
                                                        };
                                                        var issueVoters : [Vote] = (issue.votes);
                                                        issueVoters := Array.append<Vote>(issueVoters, [vote1]);
                                                        let issueUpdated = {
                                                                issueId : Nat64 = issueID; 
                                                                content : Text = issue.content;
                                                                creator : Principal = issue.caller;
                                                                created : Time.Time = issue.currentTime;
                                                                expiry : Time.Time = issue.expiry;
                                                                votes : [Vote] = [vote1];
                                                                voteScore : Int = issue.voteScore + points;
                                                        };
                                                        issues.put(issueID, issueUpdated);
                                                        // for next Issue increment counter.
                                                        issueID := issueID + 1; // increment the issue ID counter
                                                        // burn the points citizen used on this issue
                                                        let mbtTokens = await tokenCanister.burn(caller, points);
                                                        return #ok(issueID-1);
                                                };
                                        };
                                } else {
                                        return #err("Not enough points")
                                };
                        };
                        case (#err(error)) {
                                return #err("NotDAOCitizen");
                        };
                };  // end switch daoCitizen
                // return #err("Not implemented");
        };

        // Returns the Principal ID of the Webpage canister associated with this DAO
        public query func getIdWebpage() : async Principal {
                return Principal.fromText("aaaaa-aa");
        };

        /// DO NOT REMOVE - Used for local testing
        public shared query ({ caller }) func whoami() : async Principal {
                return caller;
        }


};
