module contribs.app;

import vibe.d;
import contribs.github;

shared static this()
{
    import std.process: environment;
	import std.conv: to;
    GITHUB_USER = environment.get("GITHUB_USER");
	GITHUB_PASSWORD = environment.get("GITHUB_PASSWORD");

	auto settings = new HTTPServerSettings;
	settings.port = to!ushort(environment.get("PORT", "8080"));
	settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;
    router.get("/", &indexPage);
    registerRestInterface(router, new Contributors());

    //auto routes = router.getAllRoutes();

	listenHTTP(settings, router);
	logInfo("Please open http://127.0.0.1:"~ to!string(settings.port)~"/ in your browser.");
}

@path("/contributors")
interface ContributorsAPI
{
    @path("file/:org/:repo")
    @queryParam("filename", "file")
	ContributorWithAvatar[] getFile(string _org, string _repo, string filename);
}

class Contributors : ContributorsAPI
{
override:
	ContributorWithAvatar[] getFile(string _org, string _repo, string filename)
    {
        // TODO: yield a better error message
        if (_org != "dlang")
        {
            ContributorWithAvatar[] a;
            return a;
        }
        return getContributors(_org ~ "/" ~ _repo, filename);
    }
}

void indexPage(HTTPServerRequest req,
	HTTPServerResponse res)
{
	res.writeBody("Please refer to https://github.com/dlang/contribs.dlang.io for documentation");
}
