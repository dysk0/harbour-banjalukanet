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
    property string articleTitle: "Loading..."
    property string articleDate: ""
    property string excerpt: "Loading..."
    property string articleContent: "Loading..."
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
                        var textA = json.post.content;
                        //print(textA)
                        var start = textA.indexOf('<span id="more-'+articleID+'"></span></p>')+('<span id="more-'+articleID+'"></span></p>').length;
                        var end = textA.indexOf('<div class="sharedadd');
                        if (end > 0)
                            textA = textA.substring(start, end);
                        textA = textA.replace("\n", "").replace("</p>", "").replace("\"", "").replace("<img ", '<img width="100%"')
                        textA = textA.replace("<p>", "\n\n")
                        articleContent = textA.trim();
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
            Image {
                id: myImage
                width: parent.width
                height: parent.width/imageW *imageH
                source: image
                BusyIndicator {
                    size: BusyIndicatorSize.Small
                    anchors.centerIn: myImage
                    running: myImage.status != Image.Ready
                }
            }
            Label {
                text:  new Date(articleDate).toLocaleDateString(Qt.locale(), Locale.LongFormat)
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                    bottomMargin: 0
                    topMargin: 0
                }
            }

            Label {
                text: articleTitle
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
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
                text: excerpt.replace("<p>", "").replace("</p>", "").replace("\"", "")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
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

            Label {
                text: articleContent
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                    bottomMargin: Theme.paddingLarge
                }
            }
        }
    }
}





