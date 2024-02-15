import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
module {

    // public type Role = {
    //     #Student;
    //     #Graduate;
    //     #Mentor;
    // };

    // public type Member = {
    //     name : Text;
    //     role : Role;
    // };
    public type Citizen = {
        name : Text;
        voterId : Text;
    };

    // public type ProposalId = Nat;

    // public type ProposalContent = {
    //     #ChangeManifesto : Text; // Change the manifesto to the provided text
    //     #AddGoal : Text;
    //     #AddMentor : Principal; // Upgrade the member to a mentor with the provided principal
    // };

    // public type IssueContent = {
    //     #ChangeManifesto : Text; // Change the manifesto to the provided text
    //     #AddGoal : Text;
    //     #AddMentor : Principal; // Upgrade the member to a mentor with the provided principal
    // };

    // public type ProposalStatus = {
    //     #Open;
    //     #Accepted;
    //     #Rejected;
    // };
    public type IssueStatus = {
        #Open;
        #Accepted;
        #Rejected;
    };

    public type Vote = {
        citizen : Principal; // The member who voted
        // votingPower : Nat;
        points : Nat; // how many votes on this issue
    };

    // public type Proposal = {
    //     content : ProposalContent; // The content of the proposal
    //     creator : Principal; // The member who created the proposal
    //     created : Time.Time; // The time the proposal was created
    //     executed : ?Time.Time; // The time the proposal was executed or null if not executed
    //     votes : [Vote]; // The votes on the proposal so far
    //     voteScore : Int; // A
    //     status : ProposalStatus; // The current status of the proposal
    // };
    public type IssueId = Nat64;
    public type Issue = {
        issueId : Nat64;
        content : Text; // The content of the Issue
        creator : Principal; // The member who created the proposal
        created : Time.Time; // The time the proposal was created
        expiry : Time.Time; // The time the proposal was executed or null if not executed
        votes : [Vote]; // The votes on the proposal so far
        voteScore : Nat; // A
        // status : IssueStatus; // The current status of the proposal
    };

    public type HeaderField = (Text, Text);
    public type HttpRequest = {
        body : Blob;
        headers : [HeaderField];
        method : Text;
        url : Text;
    };

    public type HttpResponse = {
        body : Blob;
        headers : [HeaderField];
        status_code : Nat16;
        streaming_strategy : ?StreamingStrategy;
    };

    public type StreamingStrategy = {
        #Callback : {
            callback : StreamingCallback;
            token : StreamingCallbackToken;
        };
    };

    public type StreamingCallback = query (StreamingCallbackToken) -> async (StreamingCallbackResponse);

    public type StreamingCallbackToken = {
        content_encoding : Text;
        index : Nat;
        key : Text;
    };

    public type StreamingCallbackResponse = {
        body : Blob;
        token : ?StreamingCallbackToken;
    };
};
