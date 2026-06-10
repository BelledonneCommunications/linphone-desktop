export function provisionedAccount(slot) {
    var prefix = slot ? ("SQUISH_SIP_" + slot + "_") : "SQUISH_SIP_";
    var username = OS.getenv(prefix + "USER");
    if (!username) {
        test.fatal("No provisioned account: " + prefix + "USER is not set");
    }
    return {
        username: username,
        password: OS.getenv(prefix + "PASS"),
        domain: OS.getenv(prefix + "DOMAIN"),
        identity: "sip:" + username + "@" + OS.getenv(prefix + "DOMAIN"),
    };
}
