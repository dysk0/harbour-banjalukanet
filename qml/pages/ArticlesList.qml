/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "Logic.js" as Logic


Page {
    id: page
    property string categoryDescription: ""
    property bool isLazyLoading: false
    property variant readed: []
    ListModel {
        id: settings
        ListElement {
            category: 0
            label: "Najnovije"
            page: 1
            refresh: false
        }
    }

    function updateData() {
        var source = ""
        var _refresh = settings.get(0).refresh;
        var _page = settings.get(0).page;
        var _category = settings.get(0).category;
        categoryDescription = settings.get(0).label;
        if (_refresh) {
            articles.model.clear();
            settings.setProperty(0, "refresh", false);
        }

        if (settings.get(0).category === 0)
            source = 'http://banjaluka.net/api/get_recent_posts/?page='+_page
        else
            source  ='http://banjaluka.net/api/get_category_posts/?id='+_category+'&page='+_page
        console.log([_category, _page, source])
        articles.source = source;
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("Categories.qml"), {"settings": settings})
            updateData()
            //myWorker.sendMessage({ 'model': articles, 'action': 'fetch', 'category': settings.get(0).category, 'page': settings.get(0).page})
        }
    }
    Component.onCompleted: {
        Logic.initialize();
    }
    Component.onDestruction: {
        Logic.saveData()
    }

    BusyIndicator {
        running: articles.count == 0
        size: BusyIndicatorSize.Large
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
    SilicaListView {
        id: listView
        visible: articles.count !== 0
        width: parent.width
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("banjaluka.net")
            description: categoryDescription
        }
        JSONListModel {
            id: articles
            source: ""
            query: "$.posts[*]"
        }
        model: articles.model
        //section.delegate: sectionDelegate
        section {
            property: 'section'


            delegate: SectionHeader {
                text: section
                height: Theme.itemSizeSmall
            }
        }

        delegate: ListItem {
            id: listItem
            opacity: Logic.isReaded(model.id) ? 0.3 : 1
            width: parent.width
            contentHeight: articleTitle.height + articleExcerpt.height+Theme.paddingMedium
            Image {
                id: icon
                y: Theme.paddingMedium
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    topMargin: Theme.paddingMedium
                }
                width: Theme.itemSizeMedium
                height: Theme.itemSizeMedium
                source: model.thumbnail_images.thumbnail.url
                BusyIndicator {
                    size: BusyIndicatorSize.Small
                    anchors.centerIn: icon
                    running: icon.status != Image.Ready
                }
                NumberAnimation on opacity {
                    id: animateImage
                    from: 0
                    to: 1
                    duration: 1200
                }
                onStatusChanged: if (icon.status == Image.Ready) {
                                     animateImage.start()
                                 }
            }
            Column {
                anchors {
                    left: icon.right
                    leftMargin: Theme.paddingMedium
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    id: articleDate
                    visible: false
                    width: parent.width
                    color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    text: model.date
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeExtraSmall * 3 / 4
                }
                Label {
                    id: articleTitle
                    width: parent.width
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: model.title
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    truncationMode: TruncationMode.Fade
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    id: articleExcerpt
                    width: parent.width
                    text: model.excerpt.replace("<p>", "").replace("</p>", "").replace("\"", "")
                    textFormat: Text.StyledText
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.WordWrap
                    truncationMode: TruncationMode.Fade
                    maximumLineCount: 3
                    color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                }
            }
            onClicked: {
                //print(JSON.stringify(articles.model.get(index)))
                Logic.markReaded(articles.model.get(index).id)
                listItem.opacity = 0.3
                var data = {
                    articleID: articles.model.get(index).id,
                    articleTitle: articles.model.get(index).title,
                    articleExcerpt: articles.model.get(index).excerpt,
                    articleDate: articles.model.get(index).date,
                    image: articles.model.get(index).thumbnail_images.full.url,
                    imageW: articles.model.get(index).thumbnail_images.full.width,
                    imageH: articles.model.get(index).thumbnail_images.full.height
                }
                pageStack.push(Qt.resolvedUrl("Article.qml"), data)

            }
        }

        footer: Item{
            width: parent.width
            height: Theme.iconSizeMedium
            Button {
                width: parent.width
                anchors.margins: Theme.paddingSmall
                onClicked: {
                    getNextData()
                }
            }
            BusyIndicator {
                size: BusyIndicatorSize.Small
                running: true;
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        VerticalScrollDecorator {}

        onContentYChanged: {
            if(contentY+200 > listView.contentHeight-listView.height-listView.footerItem.height){
                getNextData()
            }
        }

    }
    Timer {
        id: myLazyLoadingTimer
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            isLazyLoading = false;
        }
    }

    function getNextData(){
        if (!isLazyLoading) {
            var _page = settings.get(0).page;
            console.log(_page);
            settings.setProperty(0, "page", _page+1);
            _page = settings.get(0).page;
            console.log(_page);
            updateData();
            isLazyLoading = true
            myLazyLoadingTimer.start()
        }
    }


}


