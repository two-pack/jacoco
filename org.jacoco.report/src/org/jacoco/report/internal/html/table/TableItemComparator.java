/*******************************************************************************
 * Copyright (c) 2009, 2013 Mountainminds GmbH & Co. KG and Contributors
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    Marc R. Hoffmann - initial API and implementation
 *
 *******************************************************************************/
package org.jacoco.report.internal.html.table;

import java.util.Comparator;

import org.jacoco.core.analysis.ICoverageNode;

/**
 * Adapter to sort table items based on their coverage nodes.
 */
class TableItemComparator implements Comparator<ITableItem> {

	private final Comparator<ICoverageNode> comparator;

	TableItemComparator(final Comparator<ICoverageNode> comparator) {
		this.comparator = comparator;
	}

	public int compare(final ITableItem i1, final ITableItem i2) {
		return comparator.compare(i1.getNode(), i2.getNode());
	}

}