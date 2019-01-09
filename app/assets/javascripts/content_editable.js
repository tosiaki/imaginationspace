$(document).on('turbolinks:load', function(){
	$("textarea.page-content-input").hide();
	textOptionsElement = document.getElementsByClassName("text-options")[0];
	boldOptionElement = document.getElementsByClassName("bold-option")[0];
	italicOptionElement = document.getElementsByClassName("italic-option")[0];
	linkOptionElement = document.getElementsByClassName("link-option")[0];
	headingOptionElement = document.getElementsByClassName("heading-option")[0];
	strikethroughOptionElement = document.getElementsByClassName("strikethrough-option")[0];
	olOptionElement = document.getElementsByClassName("ol-option")[0];
	ulOptionElement = document.getElementsByClassName("ul-option")[0];
	blockquoteOptionElement = document.getElementsByClassName("blockquote-option")[0];

	linkAdditionFormElement = document.getElementsByClassName("link-addition-form")[0];
	linkInputElement = linkAdditionFormElement.getElementsByTagName("input")[0];
	linkButtonElement = linkAdditionFormElement.getElementsByTagName("button")[0];
	linkOptionsElement = document.getElementsByClassName("link-options")[0];
	linkEditElement = document.getElementsByClassName("link-input-edit-button")[0];
	linkRemoveElement = document.getElementsByClassName("link-input-remove-button")[0];
	linkOpenElement = document.getElementsByClassName("link-input-open-button")[0];

	lineOptionsElement = document.getElementsByClassName("line-options")[0];
	inlinePictureElement = document.getElementsByClassName("inline-picture-field")[0];

	var currentContentEditableElement;
	var range;

	function resetSelections() {
		boldOptionElement.classList.remove("selected");
		italicOptionElement.classList.remove("selected");
		linkOptionElement.classList.remove("selected");
		headingOptionElement.classList.remove("selected");
		strikethroughOptionElement.classList.remove("selected");
		ulOptionElement.classList.remove("selected");
		olOptionElement.classList.remove("selected");
		blockquoteOptionElement.classList.remove("selected");
	}

	var currentContentEditable;
	function addSelections(selection) {
		range = selection.getRangeAt(0).cloneRange();
		selectionNodes = getNodesTypesBetween(currentContentEditable, range.startContainer,range.endContainer);
		if (selectionNodes.has("B") || selectionNodes.has("STRONG")) {
			boldOptionElement.classList.add("selected");
		}
		if (selectionNodes.has("I") || selectionNodes.has("EM")) {
			italicOptionElement.classList.add("selected");
		}
		if (selectionNodes.has("A")) {
			linkOptionElement.classList.add("selected");
		}
		if (selectionNodes.has("H2")) {
			headingOptionElement.classList.add("selected");
		}
		if (selectionNodes.has("S") || selectionNodes.has("STRIKE")) {
			strikethroughOptionElement.classList.add("selected");
		}
		if (selectionNodes.has("UL")) {
			ulOptionElement.classList.add("selected");
		}
		if (selectionNodes.has("OL")) {
			olOptionElement.classList.add("selected");
		}
		if (selectionNodes.has("BLOCKQUOTE")) {
			blockquoteOptionElement.classList.add("selected");
		}
		return range;
	}

	boldOptionElement.addEventListener("click", function(clickEvent) {
		document.execCommand("bold");
		selection = window.getSelection();
		resetSelections();
		addSelections(selection);
	});
	italicOptionElement.addEventListener("click", function(clickEvent) {
		document.execCommand("italic");
		selection = window.getSelection();
		resetSelections();
		addSelections(selection);
	});
	linkOptionElement.addEventListener("click", function(clickEvent) {
		selection = window.getSelection();
		if (linkOptionElement.classList.contains("selected")) {
			document.execCommand("unlink");
			resetSelections();
			addSelections(selection);
		} else {
			range = selection.getRangeAt(0).cloneRange();
			rects = range.getClientRects();
			linkAdditionFormElement.style.display = "flex";
			positionElementWithRects(linkAdditionFormElement, currentContentEditableElement, rects);
			textOptionsElement.style.display = "none";
			linkInputElement.focus();
		}
	});
	headingOptionElement.addEventListener("click", function(clickEvent) {
		if (headingOptionElement.classList.contains("selected")) {
			document.execCommand("formatBlock", false, "<div>");
		} else {
			document.execCommand("formatBlock", false, "h2");
		}
		selection = window.getSelection();
		resetSelections();
		addSelections(selection);
	});
	strikethroughOptionElement.addEventListener("click", function(clickEvent) {
		document.execCommand("strikeThrough");
		selection = window.getSelection();
		resetSelections();
		addSelections(selection);
	});
	olOptionElement.addEventListener("click", function(clickEvent) {
		document.execCommand("insertOrderedList");
		selection = window.getSelection();
		resetSelections();
		addSelections(selection);
	});
	ulOptionElement.addEventListener("click", function(clickEvent) {
		document.execCommand("insertUnorderedList");
		selection = window.getSelection();
		resetSelections();
		addSelections(selection);
	});
	blockquoteOptionElement.addEventListener("click", function(clickEvent) {
		if (blockquoteOptionElement.classList.contains("selected")) {
			document.execCommand("formatBlock", false, "div");
		} else {
			document.execCommand("formatBlock", false, "blockquote");
		}
		selection = window.getSelection();
		resetSelections();
		addSelections(selection);
	});

	function insertLink () {
		var sel = window.getSelection();
		sel.removeAllRanges();
		sel.addRange(range);
		document.execCommand("unlink");
		document.execCommand("createLink", false, addhttp(linkInputElement.value));
		linkAdditionFormElement.style.display = "none";
		linkOptionsElement.style.display = "flex";
		positionElementWithRects(linkOptionsElement, currentContentEditableElement, rects);
	}

	linkInputElement.addEventListener("keydown", function(event) {
		var key = event.keyCode || event.charCode;
		if(key === 13) {
			event.preventDefault();
			insertLink();
		}
		setTimeout(function() {
			if(/\S/.test(linkInputElement.value)) {
				linkButtonElement.style.display = "block";
			}
		}, 10);
	});

	linkButtonElement.addEventListener("click", function(event) {
		event.preventDefault();
		insertLink();
	});
	linkEditElement.addEventListener("click", function(event) {
		event.preventDefault();
		linkAdditionFormElement.style.display = "flex";
		linkOptionsElement.style.display = "none";
	});
	linkRemoveElement.addEventListener("click", function(event) {
		event.preventDefault();
		document.execCommand("unlink");
		linkOptionsElement.style.display = "none";
		linkInputElement.value = "";
	});
	linkOpenElement.addEventListener("click", function(event) {
		event.preventDefault();
		window.open(addhttp(linkInputElement.value), "_blank");
		window.focus();
	});

	insertedImagesCount = 0;
	inlinePictureElement.addEventListener("change", function(event) {
		Array.from(inlinePictureElement.files).forEach(function(file) {
			document.execCommand("insertParagraph");
			currentParagraph = window.getSelection().getRangeAt(0).cloneRange().startContainer;

			(function(currentParagraph) {
				var uppy = Uppy.Core({
					autoProceed: true,
					restrictions: {
						allowedFileTypes: inlinePictureElement.accept.split(','),
					}
				});

				uppy.use(Uppy.AwsS3, {
					serverUrl: '/', // will call Shrine's presign endpoint on `/s3/params`
				});
				uppy.on("upload-success", function(file, data) {
					showImageElement = document.createElement('img');
					showImageElement.src = URL.createObjectURL(file.data);
					currentParagraph.appendChild(showImageElement);

					object_key = file.meta['key'].match(/^cache\/(.+)/)[1];

					// construct uploaded file data in the format that Shrine expects
					var uploadedFileData = JSON.stringify({
						id: object_key, // object key without prefix
						storage: 'cache',
						metadata: {
							size:      file.size,
							filename:  file.name,
							mime_type: file.type,
						}
					});
					showImageElement.dataset.fileData = uploadedFileData;
				});

				uppy.addFile({name: file.name, type: file.type, data: file});
			})(currentParagraph);

			++insertedImagesCount;
		});
		inlinePictureElement.value = '';
	});

	function positionElementWithRects(element, contentEditableElement, rects) {
		if (rects.length > 0) {
			rect = rects[0];
			xmid = (rect.left+rect.right)/2;

			contentEditableDivRect = contentEditableElement.getBoundingClientRect();
			leftBound = Math.max(Math.min(window.scrollX + xmid - element.offsetWidth/2, window.scrollX + contentEditableDivRect.right - element.offsetWidth), window.scrollX + contentEditableDivRect.left);
			topBound = window.scrollY + rect.top - element.offsetHeight*1.5;
			if(topBound < window.scrollY) {
				topBound = window.scrollY + rect.top + element.offsetHeight;
			}

			element.style.left = leftBound+"px";
			element.style.top = topBound+"px";
		}
	}

	function positionOnRight(element, contentEditableDiv) {
		var tempDiv = document.createElement("div");
		range.insertNode(tempDiv);
		contentEditableDivRect = contentEditableDiv.getBoundingClientRect();
		element.style.left = window.scrollX + contentEditableDivRect.right - element.offsetWidth + "px";
		element.style.top = window.scrollY + tempDiv.getBoundingClientRect().top + parseInt(contentEditableDiv.dataset.computedHeight, 10)/2 - element.offsetHeight/2 + "px";
		tempDiv.parentNode.removeChild(tempDiv);
	}

	document.addEventListener("mousedown", function() {
		var clickedOption = false;
		Array.prototype.forEach.call(textOptionsElement.childNodes, function (childNode) {
			if (childNode.contains(event.target)) {
				clickedOption = true;
			}
		});
		if(!clickedOption) {
			textOptionsElement.style.display = "none";
		}

		var clickedTextInput = false;
		if(lineOptionsElement.contains(event.target)) {
			clickedTextInput = true;
		}
		Array.prototype.forEach.call(document.getElementsByClassName("page-content-input"), function(textareaElement) {
			if (textareaElement.contains(event.target)) {
				clickedTextInput = true;
			}
		});
		if(!clickedTextInput) {
			lineOptionsElement.style.display = "none";
		}

		if(!linkAdditionFormElement.contains(event.target)) {
			linkAdditionFormElement.style.display = "none";
		}
		if(!linkOptionsElement.contains(event.target)) {
			linkOptionsElement.style.display = "none";
		}
		if(!linkAdditionFormElement.contains(event.target) && !linkOptionsElement.contains(event.target)) {
			linkInputElement.value = "";
			linkButtonElement.style.display = "none";
		}
	});

	Array.from(document.getElementsByClassName("page-content-input")).forEach(function (textareaElement) {
		bottomArea = textareaElement.parentNode;
		if (bottomArea.getElementsByClassName("javascript-editor").length === 0) {
			var contentEditableDiv = document.createElement('div');
			bottomArea.insertBefore(contentEditableDiv, textareaElement.nextSibling);
			contentEditableDiv.contentEditable = true;
			contentEditableDiv.classList = "javascript-editor article-context";
			contentEditableDiv.dataset.placeholder = textareaElement.placeholder;
			contentEditableDiv.innerHTML = textareaElement.value;
		} else {
			contentEditableDiv = bottomArea.getElementsByClassName("javascript-editor")[0];
		}
		contentEditableDiv.dataset.computedHeight = window.getComputedStyle(contentEditableDiv).getPropertyValue('line-height');

		var beginMouseEvent = false;

		function createEditingOptions(callback) {
			resetSelections();
			beginMouseEvent = false;
			selection = window.getSelection();
			setTimeout(function() {
				if (!selection.isCollapsed && (selection.baseOffset!==selection.extentOffset) && selection.rangeCount > 0) {
					range = addSelections(selection);

					rects = range.getClientRects();
					if (rects.length > 0) {
						currentContentEditableElement = contentEditableDiv;
						textOptionsElement.style.display = "block";
						positionElementWithRects(textOptionsElement, contentEditableDiv, rects)
					}
				} else {
					typeof callback === 'function' && callback();
				}
			}, 10);
		}

		function createLineOptions(selection) {
			currentContentEditableElement = contentEditableDiv;
			setTimeout(function() {
				if (selection.isCollapsed && (selection.baseOffset===selection.extentOffset) && selection.rangeCount > 0) {
					range = selection.getRangeAt(0).cloneRange();
					currentNode = range.startContainer;
					blockElementContainer = findBlockElement(currentNode);
					if(textNodesUnder(blockElementContainer).length === 0 || (blockElementContainer === contentEditableDiv && currentNode.nodeType === 3 && currentNode.nodeValue.length === 0)) {

						lineOptionsElement.style.display = "flex";
						positionOnRight(lineOptionsElement, contentEditableDiv);

					} else {
						lineOptionsElement.style.display = "none";
					}
				}
			}, 10);
		}

		contentEditableDiv.addEventListener("mousedown", function(event) {
			beginMouseEvent = true;
			currentContentEditable = contentEditableDiv;
			createLineOptions(document.getSelection());
		});

		contentEditableDiv.addEventListener("keydown", function(event) {
			var key = event.keyCode || event.charCode;
			selection = document.getSelection();
			createLineOptions(selection);
			if(key === 13) {
				range = selection.getRangeAt(0).cloneRange();
				if (blockquoteNode = findBlockquote(contentEditableDiv, range.startContainer)) {
					previousSiblingNode = blockquoteNode.previousSibling;
					if (previousSiblingNode && previousSiblingNode.nodeType === 1 && previousSiblingNode.tagName === "BLOCKQUOTE" && textNodesUnder(blockquoteNode).length === 0) {
						event.preventDefault();
						document.execCommand("formatBlock", false, "div");
					}
				}
			}
			linkOptionsElement.style.display = "none";
		});

		document.addEventListener("mouseup", function(event) {
			if(beginMouseEvent) {
				createEditingOptions();
			}
		});

		contentEditableDiv.addEventListener("keyup", function(event) {
			createEditingOptions(function() {
				textOptionsElement.style.display = "none";
			});
		});

		contentEditableDiv.addEventListener("touchend", function(event) {
			createEditingOptions();
		});

		submitElements = textareaElement.closest(".posting-form-unit").querySelectorAll("input[type=submit]");
		Array.prototype.forEach.call(submitElements, function (submitElement) {
			submitElement.addEventListener("click", function(event) {
				textareaElement.value = contentEditableDiv.innerHTML;
			});
		});
	});

	var optimizedResize = (function() {
		var callbacks = [],
			running = false;

		// fired on resize event
		function resize() {
			if (!running) {
				running = true;

				if (window.requestAnimationFrame) {
					window.requestAnimationFrame(runCallbacks);
				} else {
					setTimeout(runCallbacks, 66);
				}
			}
		}

		// run the actual callbacks
		function runCallbacks() {
			callbacks.forEach(function(callback) {
				callback();
			});

			running = false;
		}

		// adds callback to loop
		function addCallback(callback) {
	 		if (callback) {
				callbacks.push(callback);
			}
		}

		return {
	    // public method to add additional callback
			add: function(callback) {
	 			if (!callbacks.length) {
					window.addEventListener('resize', resize);
				}
				addCallback(callback);
			}
		}
	}());

	optimizedResize.add(function() {
		selection = window.getSelection();
		if(selection.rangeCount > 0 && currentContentEditableElement) {
			rects = selection.getRangeAt(0).cloneRange().getClientRects();
			[textOptionsElement, linkAdditionFormElement, linkOptionsElement].forEach(function(element) {
				if (element.style.display != "none") {
					positionElementWithRects(element, currentContentEditableElement, rects);
				}
			});
			if(lineOptionsElement.style.display != "none") {
				positionOnRight(lineOptionsElement, currentContentEditableElement);
			}
		}
	});
});

function textNodesUnder(el){
  var n, a=[], walk=document.createTreeWalker(el,NodeFilter.SHOW_TEXT,null,false);
  while(n=walk.nextNode()) a.push(n);
  return a;
}

function findBlockElement(startNode) {
	if (startNode.nodeType === 1) {
		currentStyle = startNode.currentStyle || window.getComputedStyle(startNode, "");
	}
	if (startNode.nodeType === 1 && currentStyle.display === "block") {
		return startNode;
	} else {
		return findBlockElement(startNode.parentNode);
	}
}

function findBlockquote(withinNode, startNode) {
	if (startNode.nodeType === 1 && startNode.tagName === "BLOCKQUOTE") {
		return startNode;
	} else if (withinNode === startNode) {
		return false;
	} else {
		return findBlockquote(withinNode, startNode.parentNode);
	}
}

function getNodesTypesBetween(rootNode, startNode, endNode) {
    var pastStartNode = false, reachedEndNode = false, nodeTypes = new Set();
    findNodes = new Set(['B', 'STRONG', 'I', 'EM', 'A', 'H2', 'S', 'STRIKE', 'OL', 'UL', 'BLOCKQUOTE']);

    function getNodes(node) {
    	if (node === startNode) {
    		pastStartNode = true;
    	}
    	if (node === endNode) {
    		reachedEndNode = true;
    	}
    	if (node.nodeType === 1) {
    		for(var i = 0, len = node.childNodes.length; !reachedEndNode && i < len; ++i) {
    			getNodes(node.childNodes[i]);
    		}
    		if(pastStartNode) {
    			nodeTagName = node.tagName;
    			if (findNodes.has(nodeTagName)) {
    				nodeTypes.add(nodeTagName);
    			}
    			if (node.style.fontWeight === "bold") {
    				nodeTypes.add("B");
    			}
    		}
    	}
    }

    getNodes(rootNode);
    return nodeTypes;
}

function addhttp(url) {
   if (!/^(f|ht)tps?:\/\//i.test(url)) {
      url = "http://" + url;
   }
   return url;
}