import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

Page {
    id: page

    property string link
    property string linkTitle

    ShareMethodList {
        id: shareMethodList
        anchors.fill: parent
        header: PageHeader {
            //: "List header for link sharing method list"
            //% "Share link"
            title: qsTrId("Share")
        }
        filter: "text/x-url"
        content: {
            "type": "text/x-url",
            "status": page.link,
            "linkTitle": page.linkTitle
        }

        ViewPlaceholder {
            enabled: shareMethodList.model.count === 0

            //% "No sharing accounts available"
            text: qsTrId("no-accounts")
            //% "You can add accounts in settings"
            hintText: qsTrId("no-accounts-hint")
        }
    }
}
