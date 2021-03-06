package de.wwu.md2.framework.generator.ios

import de.wwu.md2.framework.generator.util.DataContainer
import de.wwu.md2.framework.mD2.OnConditionEvent
import java.util.Date

class OnConditionEventClass
{
	private DataContainer dataContainer
	new(DataContainer dataContainer)
	{
		this.dataContainer = dataContainer
	}
	
	def createOnConditionEventH(OnConditionEvent event) '''
		//
		//  «event.name.toFirstUpper»OnConditionEvent.h
		//
		//  Generated by MD2 framework on «new Date()».
		//  Copyright (c) 2012 Uni-Muenster. All rights reserved.
		//
		
		#import "«IOSGenerator::md2LibraryImport»/OnConditionEvent.h"

		@interface «event.name.toFirstUpper»OnConditionEvent : OnConditionEvent
		@end'''
	
	def createOnConditionEventM(OnConditionEvent event) '''
		//
		//  «event.name.toFirstUpper»OnConditionEvent.m
		//
		//  Generated by MD2 framework on «new Date()».
		//  Copyright (c) 2012 Uni-Muenster. All rights reserved.
		//
		
		#import "«event.name.toFirstUpper»OnConditionEvent.h"
		#import "«event.name.toFirstUpper»Condition.h"
		
		@implementation «event.name.toFirstUpper»OnConditionEvent
		
		-(id) init
		{
		    self = [super init];
		    if (self)
		    {
		        condition = [[«event.name.toFirstUpper»Condition alloc] init];
		    }
		    return self;
		}
		
		@end'''
}