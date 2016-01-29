module.exports = function(req, res){
    res.send('body:' + req.body["name"]);
};
