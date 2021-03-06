/**
 * Copyright (c) 2018, 2019 National Digital ID COMPANY LIMITED
 *
 * This file is part of NDID software.
 *
 * NDID is the free software: you can redistribute it and/or modify it under
 * the terms of the Affero GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or any later
 * version.
 *
 * NDID is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the Affero GNU General Public License for more details.
 *
 * You should have received a copy of the Affero GNU General Public License
 * along with the NDID source code. If not, see https://www.gnu.org/licenses/agpl.txt.
 *
 * Please contact info@ndid.co.th for any further questions
 *
 */

export default class TokenManager {
  constructor() {
    this.tokens = new Object();
    this.invalidatedToken = new Object();
  }

  setGetToken(getTokenFn) {
    this.getToken = getTokenFn;
  }

  setRemoveToken(removeTokenFn) {
    this.removeToken = removeTokenFn;
  }

  setPublishRequestNewTokenEvent(publishRequestNewTokenEventFn) {
    this.publishRequestNewTokenEvent = publishRequestNewTokenEventFn;
  }

  async getTokenFromNodeId(nodeId) {
    if (this.tokens[nodeId] == undefined && this.getToken != undefined) {
      this.tokens[nodeId] = await this.getToken(nodeId);
    }
    if (this.tokens[nodeId] === this.invalidatedToken[nodeId]) {
      delete this.tokens[nodeId];
      return undefined;
    }
    return this.tokens[nodeId];
  }

  async revokeToken(nodeId) {
    this.invalidatedToken[nodeId] = this.tokens[nodeId];
    if (this.removeToken != undefined) {
      await this.removeToken(nodeId);
    }
  }

  async invalidateToken(nodeId, token) {
    const currentToken = await this.getTokenFromNodeId(nodeId);
    if (currentToken === token) {
      await this.revokeToken(nodeId);
    }
  }

  requestNewToken(nodeId) {
    if (this.publishRequestNewTokenEvent != undefined) {
      this.publishRequestNewTokenEvent(nodeId);
    }
  }
}
