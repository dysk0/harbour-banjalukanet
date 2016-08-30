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


Page {
    id: page
    property string articleTitle: ""
    property string articleDate: ""
    property string articleExcerpt: ""
    property string articleContent: ""
    property string image: ""
    property int articleID
    property int imageW
    property int imageH
    property string date: ""




    onStatusChanged: {

        if (status === PageStatus.Active) {
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.onreadystatechange = function() {
                if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                    try {
                        var json = JSON.parse(xmlHttp.responseText);
                        var originalContent = json.post.content;
                        String.prototype.replaceAll = function(search, replacement) {
                            var target = this;
                            return target.replace(new RegExp(search, 'g'), replacement);
                        };
                        var start = originalContent.indexOf('<span id="more-'+articleID+'"></span></p>')+('<span id="more-'+articleID+'"></span></p>').length;
                        var end = originalContent.indexOf('<div class="sharedadd');
                        if (end > 0)
                            originalContent = originalContent.substring(start, end);
                        originalContent = originalContent.replaceAll("\n\n", "\n").replaceAll("</p>", "").replaceAll("\"", "").replaceAll("height=", 'w--th=').replaceAll("width=", 'w--th=').replaceAll("<img ", '<img width="'+(parent.width-2*Theme.paddingLarge)+'"')

                        var stripTargetAttr = new RegExp("(<a[^>]+?)target\\s*=\\s*(?:\"|')[^\"']*(?:\"|')", "gi");
                        var tmpContent = originalContent;

                        pageStack.pushAttached(Qt.resolvedUrl("SharePage.qml"), {"link": json.post.url, linkTitle: json.post.title})

                        articleContent = originalContent.trim();
                    } catch(e) {
                        console.log(e)
                        console.log(" ######## CATEGORIES JSON ERROR ######## ");
                    }
                }
                if (xmlHttp.readyState == 4 && xmlHttp.status == 403) {
                    console.log(" ######## ERROR ######## ");
                }
            }
            xmlHttp.open('GET', "http://banjaluka.net/api/get_post/?id="+articleID)
            xmlHttp.send();
        }
    }

    SilicaFlickable {
        contentHeight: column.height
        anchors.fill: parent
        VerticalScrollDecorator {}

        Column {
            spacing: Theme.paddingLarge
            id: column
            width: parent.width

            Item {
                width: parent.width
                height: parent.width/imageW *imageH




                Image {
                    id: myImage
                    width: parent.width
                    height: parent.height
                    source: image
                    fillMode: Image.PreserveAspectCrop
                    //width: implicitWidth * 2
                    //height: implicitHeight * 2
                    BusyIndicator {
                        size: BusyIndicatorSize.Large
                        anchors.centerIn: myImage
                        running: myImage.status != Image.Ready
                    }
                    NumberAnimation on opacity {
                        id: animateImage
                        from: 0
                        to: 1
                        duration: 1200
                    }

                    onStatusChanged: if (myImage.status == Image.Ready) {
                                         animateImage.start()
                                     }
                }

                Label {
                    id: lblDate
                    text:  new Date(articleDate).toLocaleDateString(Qt.locale(), Locale.LongFormat)
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                        bottomMargin: Theme.paddingLarge
                        topMargin: 0
                    }
                }


            }

            Label {
                text: articleTitle
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                font.bold: true
                anchors {
                    left: parent.left
                    right: parent.right
                    topMargin: 0
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                    bottomMargin: Theme.paddingLarge
                }
            }

            Label {
                text: articleExcerpt.replace("<p>", "").replace("</p>", "").replace("\"", "")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                font.bold: true
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                    bottomMargin: Theme.paddingLarge
                }
            }

            BusyIndicator {
                id: busyIndicator
                x: parent.width/2-busyIndicator.width/2
                size: BusyIndicatorSize.Small
                running: articleContent === ""
                visible: articleContent  === ""
                horizontalAlignment: Qt.AlignHCenter
            }
            Label {
                readonly property string _linkStyle: "<style>a:link { color: " + Theme.primaryColor + "; } h1, h2, h3, h4 { color: " + Theme.highlightColor + "; } img { margin: "+Theme.paddingLarge+" 0}</style>"
                textFormat: Text.RichText
                text: _linkStyle + articleContent;
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                opacity: 0
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                    bottomMargin: Theme.paddingLarge
                }
                NumberAnimation on opacity {
                    id: textOpacity
                    from: 0
                    to: 1
                    duration: 2200
                }
                onTextChanged: if (articleContent !== "") {
                                   textOpacity.start()
                               }
            }
        }
    }
}





