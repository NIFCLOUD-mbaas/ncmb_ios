module.exports = function(req, res){
    if (req.query.objectId === undefined) {
        res.status(400).json({error: 'objectId must not be null'});
    } else {
        res.send("good bye.");
    }
};
