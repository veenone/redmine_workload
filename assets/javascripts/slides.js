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
