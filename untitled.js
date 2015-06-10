function findMinMax(obj) {
    var results = {
        min: 0,
        max: 0
    };
    var getMinMax = function(obj) {
        for (var prop in obj) {
            if (typeof obj[prop] === 'object') {
                getMinMax(obj[prop]);
            } else {
                if (obj[prop] > results.max) {
                    results.max = obj[prop];
                }
                if (obj[prop] < results.min) {
                    results.min = obj[prop];
                }
            }
        }
    };
    getMinMax(obj);
    return results
}
