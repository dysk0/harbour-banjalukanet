import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property ListModel settings
    onStatusChanged: {
        if (status === PageStatus.Active) {
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.onreadystatechange = function() {
                if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                    try {
                        var json = JSON.parse(xmlHttp.responseText);
                        for(var i = 0; i < json.categories.length; i++){
                            var item = json.categories[i];
                            modelCategories.append(item);
                        }

                    } catch(e) {
                        console.log(e)
                        console.log(xmlHttp.responseText)
                        console.log(" ######## CATEGORIES ######## ");
                    }
                }
                if (xmlHttp.readyState == 4 && xmlHttp.status == 403) {
                    console.log(" ######## CATEGORIES ERROR ######## ");
                }
            }

            xmlHttp.open('GET', 'http://banjaluka.net/api/get_category_index/')
            xmlHttp.send();
        }
    }
    ListModel {
        id: modelCategories
    }
    BusyIndicator {
        running: modelCategories.count == 0
        size: BusyIndicatorSize.Large
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
    SilicaListView {
        id: listView
        model: modelCategories
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Kategorije")
        }
        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                text: model.title
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            Label {
                x: Theme.paddingLarge
                text: model.post_count
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                color: delegate.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            }
            onClicked: {
                console.log("Clicked " + model.id)
                if (settings.get(0).category !== model.id){
                    settings.setProperty(0, "refresh", true);
                    settings.setProperty(0, "page", 1);
                    settings.setProperty(0, "label", model.title);
                    settings.setProperty(0, "category", model.id);
                }
                pageStack.navigateBack()
            }
        }
        VerticalScrollDecorator {}
    }
}


