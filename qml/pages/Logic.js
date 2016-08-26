.import QtQuick.LocalStorage 2.0 as LS
var db = LS.LocalStorage.openDatabaseSync("BanjaLukaNet", "", "nwallet", 100000);
var readedItems = [];
function initialize() {
    console.log("db.version: "+db.version);
    if(db.version === '') {
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings ('
                          + ' key TEXT UNIQUE, '
                          + ' value TEXT '
                          +');');
            tx.executeSql('INSERT INTO settings (key, value) VALUES (?, ?)', ["readed", ""]);
        });
        db.changeVersion('', '0.1', function(tx) {
        });
    }
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM settings;');
        for (var i = 0; i < rs.rows.length; i++) {
            //var json = JSON.parse(rs.rows.item(i).value);
            console.log("READED in DB: "+rs.rows.item(i).value)
            if ( rs.rows.item(i).key === "readed")
                readedItems = rs.rows.item(i).value.split(",")
        }
    });
}


function getReaded() {
    return readedItems;
}
function isReaded(id) {
    if (readedItems.indexOf(id+"") !== -1){
        return true;
    } else {
        return false;
    }
}

function markReaded(id) {
    readedItems.push(id)
}

function saveData() {
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE settings SET value = ? WHERE key = ?', [readedItems.join(","), "readed"]);
        console.log("Saving... "+JSON.stringify(readedItems)+"\n"+JSON.stringify(rs))
    });
}

