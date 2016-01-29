module.exports = function(req, res){
    if (req.query.objectId === undefined) {
        console.log("error:" + {error: "object id must not be null"});
        res.status(400).json({ error: 'objectId must not be null'});
    }
    if(req.body["name"] !== undefined){
        console.log("hello:" + req.body["name"]);
        res.send('hello,' + req.body["name"]);
    }else {
        console.log("hello");
        res.send('hello');
    }
};
