/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package com.epam.dlab.backendapi.dao;

import com.epam.dlab.auth.UserInfo;

public interface BillingDAO {
	Double getTotalCost(UserInfo userInfo);

	Double getUserCost(String user, UserInfo userInfo);

	Double getProjectCost(String project, UserInfo userInfo);

	int getBillingQuoteUsed(UserInfo userInfo);

	int getBillingUserQuoteUsed(String user, UserInfo userInfo);

	int getBillingProjectQuoteUsed(String project, UserInfo userInfo);

	boolean isBillingQuoteReached(UserInfo userInfo);

	boolean isUserQuoteReached(String user, UserInfo userInfo);

	boolean isProjectQuoteReached(String project, UserInfo userInfo);
}
