module git.c.push;

/*
 * Copyright (C) the libgit2 contributors. All rights reserved.
 *
 * This file is part of libgit2, distributed under the GNU GPL v2 with
 * a Linking Exception. For full terms see the included COPYING file.
 */

/**
 * @file git2/push.h
 * @brief Git push management functions
 * @defgroup git_push push management functions
 * @ingroup Git
 * @{
 */

import git.c.common;
import git.c.types;

extern (C):

/**
 * Controls the behavior of a git_push object.
 */
struct git_push_options {
	uint version_ = GIT_PUSH_OPTIONS_VERSION;

	/**
	 * If the transport being used to push to the remote requires the creation
	 * of a pack file, this controls the number of worker threads used by
	 * the packbuilder when creating that pack file to be sent to the remote.
	 *
	 * If set to 0, the packbuilder will auto-detect the number of threads
	 * to create. The default value is 1.
	 */
	uint pb_parallelism;
} ;

enum GIT_PUSH_OPTIONS_VERSION = 1;
enum git_push_options GIT_PUSH_OPTIONS_INIT = { GIT_PUSH_OPTIONS_VERSION };

/**
 * Create a new push object
 *
 * @param out New push object
 * @param remote Remote instance
 *
 * @return 0 or an error code
 */
int git_push_new(git_push **out_, git_remote *remote);

/**
 * Set options on a push object
 *
 * @param push The push object
 * @param opts The options to set on the push object
 *
 * @return 0 or an error code
 */
int git_push_set_options(
	git_push *push,
	const(git_push_options)* opts);

/**
 * Add a refspec to be pushed
 *
 * @param push The push object
 * @param refspec Refspec string
 *
 * @return 0 or an error code
 */
int git_push_add_refspec(git_push *push, const(char)* refspec);

/**
 * Update remote tips after a push
 *
 * @param push The push object
 *
 * @return 0 or an error code
 */
int git_push_update_tips(git_push *push);

/**
 * Actually push all given refspecs
 *
 * Note: To check if the push was successful (i.e. all remote references
 * have been updated as requested), you need to call both
 * `git_push_unpack_ok` and `git_push_status_foreach`. The remote
 * repository might have refused to update some or all of the references.
 *
 * @param push The push object
 *
 * @return 0 or an error code
 */
int git_push_finish(git_push *push);

/**
 * Check if remote side successfully unpacked
 *
 * @param push The push object
 *
 * @return true if equal, false otherwise
 */
int git_push_unpack_ok(git_push *push);

/**
 * Call callback `cb' on each status
 *
 * For each of the updated references, we receive a status report in the
 * form of `ok refs/heads/master` or `ng refs/heads/master <msg>`.
 * `msg != NULL` means the reference has not been updated for the given
 * reason.
 *
 * @param push The push object
 * @param cb The callback to call on each object
 *
 * @return 0 on success, GIT_EUSER on non-zero callback, or error code
 */

int git_push_status_foreach(
    git_push *push,
    int function(const(char)* ref_, const(char)* msg, void *data) cb,
	void *data);

/**
 * Free the given push object
 *
 * @param push The push object
 */
void git_push_free(git_push *push);




