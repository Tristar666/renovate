export interface GitlabIssue {
  iid: number;
  title: string;
}

export interface GitlabComment {
  body: string;
  id: number;
}

export interface Mr {
  state: string;
  merge_status: string;
  pipeline: Pipeline;
  has_conflicts: boolean;
}

export interface Pipeline {
  status: string;
}

export type MergeMethod = 'merge' | 'rebase_merge' | 'ff';

export type RepoResponse = {
  archived: boolean;
  mirror: boolean;
  default_branch: string;
  empty_repo: boolean;
  http_url_to_repo: string;
  forked_from_project: boolean;
  repository_access_level: 'disabled' | 'private' | 'enabled';
  merge_requests_access_level: 'disabled' | 'private' | 'enabled';
  merge_method: MergeMethod;
  path_with_namespace: string;
};
