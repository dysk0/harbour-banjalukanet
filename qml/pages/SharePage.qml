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
            //: List header for link sharing method list
            //% "Share link"
            title: qsTrId("sailfish_browser-he-share_link")
        }
        filter: "text/x-url"
        content: {
            "type": "text/x-url",
            "status": page.link,
            "linkTitle": page.linkTitle
        }

        ViewPlaceholder {
            enabled: shareMethodList.model.count === 0

            //: Empty state for share link page
            //% "No sharing accounts available. You can add accounts in settings"
            text: qsTrId("sailfish_browser-la-no_accounts")
        }
    }
}
