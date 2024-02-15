import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Types "types";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
// import Nat "mo:base/Int";
import Nat64 "mo:base/Nat64";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

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
        stable var manifesto = "Manifesto - Implement government Budget through DAO by citizens direct voting";
        stable let name = "A Government DAO";
        stable var webIssues : [Issue]= [];
        stable var issueID: Nat64 = 0;

        let citizens : HashMap.HashMap<Principal, Citizen> = HashMap.HashMap<Principal, Citizen>(0, Principal.equal, Principal.hash);


        // Define an async function to call tokenSymbol
        public func getDVTTokenSymbol() : async Text {
                let tokenDVTSymbol = await tokenCanister.tokenSymbol();
                return tokenDVTSymbol;
        };

        // Define an async function to call tokenName
        public func getDVTTokenName() : async Text {
                let tokenDVTName = await tokenCanister.tokenName();
                return tokenDVTName;
        };

        // let tokenCan = await tokenCanister.tokenSymbol(); 

        // Returns the name of the DAO
        public query func getDaoName() : async Text {
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

        // Returns all the Citizens
        public query func getAllCitizens() : async [Citizen] {
                return Iter.toArray(citizens.vals());
        };

        public shared ({ caller }) func getBalance() : async Nat {
            let myBalance = await tokenCanister.balanceOf(caller);
            return myBalance;
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
                                        let sixMonthsInNanoSeconds : Nat = (30 * 24 * 60 * 60 * 6) * 1_000_000_000;
                                        var expiry : Time.Time = Time.now();
                                        let currentTime = Time.now();
                                        expiry := (currentTime + sixMonthsInNanoSeconds);
                                        // identify who voted as we are transparent
                                        let vote1 : Vote = {
                                                citizen = caller;
                                                points = points;
                                        };        
                                        issueID := issueID + 1;   // when we create new issue we increment.                                
                                        let issue = {
                                                issueId : Nat64 = issueID; 
                                                content : Text = content;
                                                creator : Principal = caller;
                                                created : Time.Time = currentTime;
                                                expiry : Time.Time = expiry;
                                                votes : [Vote] = [vote1];
                                                voteScore : Nat = points;
                                                // status : Types.IssueStatus = propStatus;
                                        };
                                        issues.put(issueID, issue);
                                        
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
        public query func getIssue(id : IssueId) : async Result<Issue, Text> {
            switch(issues.get(id)) {
              case(null) { return #err("no issue with that id") };
              case(?issue) { return #ok(issue);  };   //return #ok(issueID);
            };
        };
                


        // Returns all the Issues
        public query func getAllIssues() : async [Issue] {
                webIssues := Iter.toArray(issues.vals());
                return Iter.toArray(issues.vals());
        };

        // Returns all the Issues
        private func _getAllIssues() : [Issue] {
                return Iter.toArray(issues.vals());
        };

        // private func _getAllIssues() : [Issue] {
        //         var issueArray : [Issue] = [];
        //         for ((_, issue) in issues.entries()) {
        //                 issueArray := Array.append(issueArray, [issue]);
        //         };
        //         return issueArray;
        // };


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
                                                                issueId : Nat64 = issue.issueId; 
                                                                content : Text = issue.content;
                                                                creator : Principal = issue.creator;
                                                                created : Time.Time = issue.created;
                                                                expiry : Time.Time = issue.expiry;
                                                                votes : [Vote] = issueVoters;
                                                                voteScore : Nat = (issue.voteScore + points);
                                                        };
                                                        issues.put(issue.issueId, issueUpdated);
                                                        // burn the points citizen used on this issue
                                                        let dvtTokens = await tokenCanister.burn(caller, points);
                                                        return #ok(issue.issueId);
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

        // // Returns the Principal ID of the Webpage canister associated with this DAO
        // public query func getIdWebpage() : async Principal {
        //         return Principal.fromText("aaaaa-aa");
        // };


        stable var logo : Text = "<?xml version='1.0' encoding='UTF-8'?>
        <svg xmlns='http://www.w3.org/2000/svg' id='Layer_1' data-name='Layer 1' viewBox='0 0 24 24'>
        <path d='m3.5,20c1.103,0,2-.897,2-2s-.897-2-2-2-2,.897-2,2,.897,2,2,2Zm0-3c.551,0,1,.448,1,1s-.449,1-1,1-1-.448-1-1,.449-1,1-1Zm6.5,1c0,1.103.897,2,2,2s2-.897,2-2-.897-2-2-2-2,.897-2,2Zm3,0c0,.552-.449,1-1,1s-1-.448-1-1,.449-1,1-1,1,.448,1,1Zm-1-14c1.103,0,2-.897,2-2s-.897-2-2-2-2,.897-2,2,.897,2,2,2Zm0-3c.551,0,1,.448,1,1s-.449,1-1,1-1-.448-1-1,.449-1,1-1Zm6.5,17c0,1.103.897,2,2,2s2-.897,2-2-.897-2-2-2-2,.897-2,2Zm3,0c0,.552-.449,1-1,1s-1-.448-1-1,.449-1,1-1,1,.448,1,1ZM4,14h-1v-2c0-1.103.897-2,2-2h14c1.103,0,2,.897,2,2v2h-1v-2c0-.552-.449-1-1-1h-6.5v3h-1v-3h-6.5c-.551,0-1,.448-1,1v2Zm3,9v1h-1v-1c0-.552-.449-1-1-1h-3c-.551,0-1,.448-1,1v1H0v-1c0-1.103.897-2,2-2h3c1.103,0,2,.897,2,2Zm17,0v1h-1v-1c0-.552-.449-1-1-1h-3c-.551,0-1,.448-1,1v1h-1v-1c0-1.103.897-2,2-2h3c1.103,0,2,.897,2,2Zm-8.5,0v1h-1v-1c0-.552-.449-1-1-1h-3c-.551,0-1,.448-1,1v1h-1v-1c0-1.103.897-2,2-2h3c1.103,0,2,.897,2,2Zm-6-15h-1v-1c0-1.103.897-2,2-2h3c1.103,0,2,.897,2,2v1h-1v-1c0-.552-.449-1-1-1h-3c-.551,0-1,.448-1,1v1Z'/>
        </svg>";

        // stable var logo : Text = "<img src='http://localhost:8000/?canisterId=your-asset-canister-id&path=/your-image-name.png' alt='Logo' />";


        func _getWebpage() : Text {

                var webpage = "<style>" #
                "body { text-align: center; font-family: Arial, sans-serif; background-color: #f0f8ff; color: #333; }" #
                "h1 { font-size: 3em; margin-bottom: 10px; }" #
                "hr { margin-top: 20px; margin-bottom: 20px; }" #
                "em { font-style: italic; display: block; margin-bottom: 20px; }" #
                "ul { list-style-type: none; padding: 0; }" #
                "li { margin: 10px 0; }" #
                "li:before { content: '👉 '; }" #
                "svg { max-width: 150px; height: auto; display: block; margin: 20px auto; }" #
                "h2 { text-decoration: underline; }" #
                "</style>";

                webpage := webpage # "<div><h1>" # name # "</h1></div>";
                webpage := webpage # "<em>" # manifesto # "</em>";
                webpage := webpage # "<div>" # logo # "</div>";
                webpage := webpage # "<hr>";

                webpage := webpage # "<div><h2>" # "Issues list" # "</h2></div>";
                // webpage := webpage # "<button id='fetchIssues'>Fetch Issues</button>";
                webpage := webpage # "<ul id='issuesList'> </ul>"; // Placeholder for the issues
                webpage := webpage # "<ul>";

                let wIssues : [Issue] = _getAllIssues();
                for (webIssue in wIssues.vals()) {
                // let webIssue : Issue = webIssues[0];
                    let wId : Text = Nat64.toText(webIssue.issueId);
                    let wScore : Text = Nat.toText(webIssue.voteScore);
                    webpage := webpage # "<li>" # "Issue: " # webIssue.content # " Issue id: " # wId #  " Total score : " # wScore # "</li>";
                    let webVotersPoints = webIssue.votes;
                    for (webVP in webVotersPoints.vals()) {
                        let wPoints : Text = Nat.toText(webVP.points);
                        let wPrincipal : Text = Principal.toText(webVP.citizen);
                            // webpage := webpage # "<li>" # "issue : " # webIssue.content # " Issue Id : " # wId # </li>";
                        webpage := webpage # "<li>" # "Voter: " # wPrincipal # " Points: " # wPoints #  "</li>";
                    };
                };

                webpage := webpage # "</ul>";                


                // webpage := webpage # "<script>
                // document.getElementById('fetchIssues').addEventListener('click', await function() {
                //         // Assuming you have set up the dfx agent and have the actor ready
                //         const issues = await myActor.getAllIssues();
                //         const issuesList = document.getElementById('issuesList');
                //         issuesList.innerHTML = ''; // Clear existing list
                //         issues.forEach(issue => {
                //         const li = document.createElement('li');
                //         li.textContent = issue.toString(); // Adjust based on how you want to display issues
                //         issuesList.appendChild(li);
                //         });
                // });
                // </script>";


                // webpage := webpage # "<h2>Our goals:</h2>";
                // webpage := webpage # "<ul>";
                // for (goal in goals.vals()) {
                // webpage := webpage # "<li>" # goal # "</li>";
                // };
                // webpage := webpage # "</ul>";
                return webpage;
        };

        public query func http_request(request : HttpRequest) : async HttpResponse {
        // Asynchronously fetch the manifesto from the other canister
        // let manifestoText = await daoCanister.getManifesto();
        // Now pass the fetched manifestoText to _getWebpage
        // let webpageContent = _getWebpage(manifestoText);
                return ({
            // status_code = 404;
            status_code = 200 : Nat16;  // 200 means everything is correct
            // headers = [];
            headers = [("Content-Type", "text/html; charset=UTF-8")];  // return HTML page
            // body = Text.encodeUtf8("Hello world!");
            
            body = Text.encodeUtf8(_getWebpage());
            streaming_strategy = null;
        });
        };

        /// DO NOT REMOVE - Used for local testing
        public shared query ({ caller }) func whoami() : async Principal {
                return caller;
        };

        
};
