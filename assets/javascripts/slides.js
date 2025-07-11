/**
	Toggle along the hierarchie tree.
	When opening, open level by level. When closing, close the item with all 
	lower levels at once.
 */

$(document).ready(function() {
	// Collapsible fieldsets functionality
	window.toggleFieldset = function(legend) {
		var fieldset = $(legend).closest('fieldset');
		var contentDiv = fieldset.find('> div').first();
		var icon = $(legend).find('.icon');
		
		if (contentDiv.is(':visible')) {
			contentDiv.hide();
			fieldset.addClass('collapsed');
			$(legend).removeClass('icon-expanded').addClass('icon-collapsed');
			icon.removeClass('icon-angle-down').addClass('icon-angle-right');
		} else {
			contentDiv.show();
			fieldset.removeClass('collapsed');
			$(legend).removeClass('icon-collapsed').addClass('icon-expanded');
			icon.removeClass('icon-angle-right').addClass('icon-angle-down');
		}
	};

	// Initialize workload table horizontal scrolling
	function initWorkloadScrolling() {
		var scrollContainer = $('.workload-horizontal-scroll');
		if (scrollContainer.length === 0) return;

		// Ensure sticky positioning works correctly
		var stickyElements = $('.workload-fixed-column, .user-description, .group-description, .project-description, .issue-description, .invisible-workload-description');
		
		// Add a class to indicate scrolling state for better visual feedback
		scrollContainer.on('scroll', function() {
			var scrollLeft = $(this).scrollLeft();
			if (scrollLeft > 0) {
				$(this).addClass('is-scrolled');
			} else {
				$(this).removeClass('is-scrolled');
			}
		});

		// Ensure table renders correctly
		setTimeout(function() {
			scrollContainer.trigger('scroll');
		}, 100);
	}

	// Initialize on page load
	initWorkloadScrolling();

	
	// Make sure CSV export button is clickable
	$(document).on('click', '.workload-menu-button', function(e) {
		var onclick = $(this).attr('onclick');
		if (onclick) {
			try {
				// Wrap the onclick code in a function to handle return statements
				var func = new Function(onclick);
				var result = func.call(this);
				if (result === false) {
					e.preventDefault();
				}
			} catch (err) {
				// Fallback - if it's the CSV export, call showModal directly
				if (onclick.includes('showModal')) {
					showModal('csv-export-options', '330px');
					e.preventDefault();
				}
			}
		}
	});

	// Modal functionality for CSV export
	window.showModal = function(elementId, width) {
		var modal = $('#' + elementId);
		if (modal.length === 0) return;

		// Create overlay if it doesn't exist
		if ($('#modal-overlay').length === 0) {
			$('body').append('<div id="modal-overlay" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; display: none;"></div>');
		}

		// Position and show the modal
		modal.css({
			'position': 'fixed',
			'top': '20%',
			'left': '50%',
			'width': width || '400px',
			'margin-left': '-' + (parseInt(width || '400') / 2) + 'px',
			'background': '#fff',
			'border': '1px solid #ccc',
			'border-radius': '4px',
			'padding': '20px',
			'box-shadow': '0 4px 8px rgba(0,0,0,0.3)',
			'z-index': '1001'
		});

		$('#modal-overlay').show();
		modal.show();

		// Close modal when clicking overlay
		$('#modal-overlay').off('click').on('click', function() {
			hideModal();
		});
	};

	window.hideModal = function(element) {
		$('#modal-overlay').hide();
		$('[id$="-options"]').hide(); // Hide all modal options
		
		// If element is a submit button, let the form submission continue
		if (element && ($(element).is('input[type="submit"]') || $(element).is('button[type="submit"]'))) {
			// Don't prevent form submission
			return true;
		}
		return false;
	};

	$('.trigger').click(function() {
		var OPENED = '&#x1F4C2;'
		var CLOSED = '&#x1F4C1;'
		$(this).toggleClass('closed opened');

		identifier = $(this).attr('data-for');
		identifierClasses = identifier.trim().replace(/\s/g, ".");

		// topDownHierarchieChain shows current hierarchie level on the left and the css
		// class of the next hierarchie level on the right hand side.
		topDownHierarchieChain = new Map([
			["group-description " + identifier, ".user-total-workload-in-" + identifierClasses],
			["user-description " + identifier, ".project-total-workload." + identifierClasses],
			["project-description " + identifier, ".issue-workloads." + identifierClasses]
		]);

		// bottomUpHierarchies shows current hierarchie level on the left and all  
		// lower hierarchie levels on the right hand side.
		bottomUpHierarchieChain = new Map([
			["group-description " + identifier, [".issue-workloads." + identifierClasses, 
																					 ".project-total-workload." + identifierClasses, 
																					 ".user-total-workload-in-" + identifierClasses]],
			["user-description " + identifier, [".issue-workloads." + identifierClasses,
																					".project-total-workload." + identifierClasses]],
			["project-description " + identifier, [".issue-workloads." + identifierClasses]]
		]);

		currentHierarchieLevel = $(this).parent().attr('class');

		if ($(this).hasClass('opened')) {
			$(this).show();
			// Shows additional info
			$(this).siblings().show();
			// Reveals the next hierarchie level 
			nextHierarchieLevelClass = topDownHierarchieChain.get(currentHierarchieLevel);
			$(nextHierarchieLevelClass).each(function(){
				$(this).show(); // but keep its 'children' closed if any
				$(this).siblings('.invisible-issues-summary.' + identifierClasses).show();
			});
			$(this).html(OPENED);
		}
		else {
			lowerHierarchieLevelClasses = bottomUpHierarchieChain.get(currentHierarchieLevel);
			// Collapses all lower levels of the currentHierarchieLevel at once 
			// as defined in bottomUpHierarchieChain.
			lowerHierarchieLevelClasses.forEach(function(css){
				$(css).hide();
				$(css).siblings('.invisible-issues-summary.' + identifierClasses).hide();
				currentHierarchieLevel = $(css).find('span.trigger.opened');
				currentHierarchieLevel.html(CLOSED);
				currentHierarchieLevel.siblings('dl').hide();
			})
			$(this).siblings().hide();
			$(this).html(CLOSED);
		}
	});
});
